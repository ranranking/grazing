subroutine model_output
  
  use parameter_var
  use structure

  implicit none

!==============================
! Cell level output
!==============================


  ! CELL(y_dim,x_dim)%TOT_BIOMASS=sum(CELL(y_dim,x_dim)%TOT_BIO_SPP(:))
  ! ! Output for species total biomass in each cell
  ! do cur_pla=1,PLA_SPP_NUM
  !   write(OUTPUT_DIR,'(A19,I1)')'/out/totbio_pla_',cur_pla
  !   open(OUTPUT_NUM+cur_pla, FILE=CWD(1:len_trim(CWD))//OUTPUT_DIR(1:len_trim(OUTPUT_DIR))//'.csv',STATUS='REPLACE'&
  !                                                                     ,ACTION='WRITE',IOSTAT=ioerr)
  !     if (ioerr .ne. 0) then
  !       write(*,*) 'outputfile can not be opened'
  !       stop
  !     end if
  !
  !   write(OUTPUT_NUM+cur_pla,*) ' '
  !   write(OUTPUT_NUM+cur_pla,*)  day,','
  !   do y_dim=1,MAX_Y_DIM
  !     write(OUTPUT_NUM+cur_pla,*) (CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla), x_dim=1,MAX_X_DIM)
  !     ! do x_dim=1,MAX_X_DIM
  !     !   write(OUTPUT_NUM+cur_pla,*) CELL(y_dim, x_dim)%TOT_BIO_SPP(cur_pla),','
  !     ! end do ! end looping for x
  !   end do ! end looping for y
  !
  !   ! do y_dim=1,MAX_Y_DIM
  !   !   write(OUTPUT_NUM+cur_pla,*) (CELL(y_dim,x_dim)%AV_BIO_SPP(cur_pla), x_dim=1,MAX_X_DIM)
  !   ! end do ! end looping for y
  !   !
  !   ! do y_dim=1,MAX_Y_DIM
  !   !   write(OUTPUT_NUM+cur_pla,*) (CELL(y_dim,x_dim)%UAV_BIO_SPP(cur_pla), x_dim=1,MAX_X_DIM)
  !   ! end do ! end looping for y
  !
  !   close(OUTPUT_NUM+cur_pla)
  ! end do ! end looping for plant species


!==============================
! Global level output (daily)
!==============================

! Global species biomass

  do cur_pla=1,PLA_SPP_NUM

    SPP_BIOMASS(cur_pla)=0
    do y_dim=1,MAX_Y_DIM
      do x_dim=1,MAX_X_DIM
        SPP_BIOMASS(cur_pla)=SPP_BIOMASS(cur_pla)+CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)
      end do
    end do

    ! inquire(unit=OUTPUT_NUM+cur_pla, opened=isopen)
    ! if (isopen .eq. .false.) then
    !   write(OUTPUT_DIR,'(A23,I1)')'/output/glo_totbio_pla_',cur_pla
    !   open(OUTPUT_NUM+cur_pla, FILE=CWD(1:len_trim(CWD))//OUTPUT_DIR(1:len_trim(OUTPUT_DIR))//'.csv',STATUS='REPLACE'&
    !                                                                   ,ACTION='WRITE',IOSTAT=ioerr)
    !   if (ioerr .ne. 0) then
    !     write(*,*) 'Species global total biomass outputfile can not be opened'
    !     stop
    !   end if
    ! end if
    !
    ! write(OUTPUT_NUM+cur_pla,*) SPP_BIOMASS(cur_pla),','

    ! close(OUTPUT_NUM+cur_pla)

  end do ! end looping for plant species

! Global total biomass

    TOT_BIOMASS=sum(SPP_BIOMASS(:))

    write(OUTPUT_DIR,'(A18)')'/out/glo_totbio'

    inquire(unit=OUTPUT_NUM, opened=isopen)
    if (isopen .eq. .false.) then
    open(OUTPUT_NUM, FILE=CWD(1:len_trim(CWD))//OUTPUT_DIR(1:len_trim(OUTPUT_DIR))//'.csv',STATUS='REPLACE'&
                                                                      ,ACTION='WRITE',IOSTAT=ioerr)
      if (ioerr .ne. 0) then
        write(*,*) 'Global total plant biomass outputfile can not be opened'
        stop
      end if
    end if

    write(OUTPUT_NUM,*) TOT_BIOMASS,','

    ! close(OUTPUT_NUM)

end subroutine model_output