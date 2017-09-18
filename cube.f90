PROGRAM cube
  USE xios

  IMPLICIT NONE


  INCLUDE "mpif.h"
  INTEGER :: comm, rank, size, ierr
  INTEGER :: cart_comm, ndims = 3, size3d(3) = 2, rank3d(3), periodic(3) = 0
  
  INTEGER :: ts
  TYPE(xios_duration) :: dtime

  ! global domain sizes
  INTEGER :: gloDomSize(3) = 60
  ! local domain size and offset
  INTEGER :: locDomSize(3), locDomStart(3), locDomEnd(3)
  
  ! local data
  DOUBLE PRECISION, ALLOCATABLE :: l_x(:), l_y(:), l_z(:), l_temp(:,:,:)
  ! Indexing
  INTEGER :: li, lj, lk, gi, gj, gk
  
  ! XIOS initialization
  CALL xios_initialize("cube", return_comm=comm)
  
  ! Figure out our decomposition etc
  CALL MPI_Comm_rank(comm, rank, ierr)
  CALL MPI_Comm_size(comm, size, ierr)
  ! Assume this will run on 8 ranks
  IF (size3d(1)*size3d(2)*size3d(3) .ne. size) THEN
     CALL MPI_Abort(comm,1)
  END IF

  CALL MPI_Cart_create(comm, ndims, size3d, periodic, 1, cart_comm, ierr)
  CALL MPI_Cart_get(cart_comm, ndims, size3d, periodic, rank3d, ierr)

  locDomSize = gloDomSize / size3d
  locDomStart = rank3d*locDomSize
  locDomEnd = locDomStart + locDomSize
  
  ALLOCATE(l_x(0:locDomSize(1)-1))
  ALLOCATE(l_y(0:locDomSize(2)-1))
  ALLOCATE(l_z(0:locDomSize(3)-1))
  ALLOCATE(l_temp(0:locDomSize(1)-1, 0:locDomSize(2)-1, 0:locDomSize(3)-1))

  DO li = 0, locDomSize(1)
     gi = locDomStart(1) + li
     l_x(li) = gi
  END DO
  DO lj = 0, locDomSize(2)
     gj = locDomStart(2) + lj
     l_y(lj) = gj
  END DO
  DO lk = 0, locDomSize(3)
     gk = locDomStart(3) + lk
     l_z(lk) = gk
  END DO

  DO li = 0, locDomSize(1)-1
     gi = locDomStart(1) + li
     DO lj = 0, locDomSize(2)-1
        gj = locDomStart(2) + lj
        DO lk = 0, locDomSize(3)-1
           gk = locDomStart(3) + lk
           l_temp(li, lj, lk) = (gi*gloDomSize(2) + gj) * gloDomSize(3) + gk
        END DO
     END DO
  END DO
  
  CALL xios_context_initialize("cube", comm)
  ! Set the sizes of the grid
  CALL xios_set_domain_attr("xy", ni_glo=gloDomSize(1), ibegin=locDomStart(1), ni=locDomSize(1))
  CALL xios_set_domain_attr("xy", nj_glo=gloDomSize(2), jbegin=locDomStart(2), nj=locDomSize(2))
  CALL xios_set_axis_attr("z", n_glo=gloDomSize(3), begin=locDomStart(3), n=locDomSize(3))

  ! Setting time step
  dtime%second=3600
  CALL xios_set_timestep(dtime)
  ! Closing definition
  CALL xios_close_context_definition()
  
  ! Entering time loop
  DO ts=1,96
     CALL xios_update_calendar(ts)
     CALL xios_send_field("temp", l_temp)
  ENDDO
  
  ! XIOS finalization
  CALL xios_context_finalize()
  CALL xios_finalize()
  
END PROGRAM cube
