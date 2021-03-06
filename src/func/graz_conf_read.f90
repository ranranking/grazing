! This subroutine runs when season has changed or on day one
subroutine graz_conf_read

  use parameter_var
  use structure
  use misc
  implicit none

  integer :: i, j
  logical :: OK             ! Used to check whether one file has been opened

  ! ! Loading misc functions {{{
  ! interface
  !
  !   ! Subroutine for Check and reallocate dimensional variables {{{
  !   subroutine check_and_reallocate(DVAR,D)
  !       implicit none
  !       real, dimension(:), allocatable, intent(out):: DVAR
  !       integer, intent(in) :: D
  !   end subroutine check_and_reallocate 
  !   subroutine check_and_reallocate_two(DVAR,D1,D2)
  !       implicit none
  !       real, dimension(:,:), allocatable, intent(out):: DVAR
  !       integer, intent(in) :: D1,D2
  !   end subroutine check_and_reallocate_two !}}}
  !
  ! end interface !}}}

    ! # First close configuration opened for last season if there is a last season
    inquire(GR_CON_SEA, opened=OK)
    if(OK) close(GR_CON_SEA)

    ! # Open general grazing configuration file
    open(GR_CON_SEA, file=CWD(1:len_trim(CWD))//PRE_DIR_GC(1:len_trim(PRE_DIR_GC))//&
                SEASON(1:len_trim(SEASON))//'.gr', action='read', iostat=ioerr)

    if (ioerr .ne. 0) then
      write(*,*) 'Grazing configuration file not opened'
      stop
    end if

    ! ------------------------
    ! # Animal species number {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      ! ## If species difference switch is on
      if (SPP_SW .eq. 1) then

        read(GR_CON_SEA,*,iostat=ioerr) ANI_SPP_NUM
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Animal species number reading error'
          stop
        else
          write(ECHO_NUM,*) 'Animal species difference exist, number of species is: '
          write(ECHO_NUM,*) ANI_SPP_NUM
        end if

      else

      ! ## If species difference is off, species number is set to 1
        ANI_SPP_NUM=1
        read(GR_CON_SEA,*)      ! skip this line

      end if

      ! ## Allocate species different variables {{{
      call check_and_reallocate(FIX_GR_R,ANI_SPP_NUM)
      call check_and_reallocate(SPP_SD,ANI_SPP_NUM)
      call check_and_reallocate(MAX_SD,ANI_SPP_NUM)
      call check_and_reallocate(MIN_SD,ANI_SPP_NUM)
      call check_and_reallocate(ANI_NUM_SPP,ANI_SPP_NUM)
      call check_and_reallocate(MAX_INT,ANI_SPP_NUM)
      call check_and_reallocate(TOT_DMD,ANI_SPP_NUM)
      call check_and_reallocate(ANI_COM_FAC,ANI_SPP_NUM)
      call check_and_reallocate(ANI_AV_BIO,ANI_SPP_NUM)
      call check_and_reallocate(DET_RATE,ANI_SPP_NUM)
      call check_and_reallocate(SC_VAR_A,ANI_SPP_NUM)
      call check_and_reallocate(N_RET_RATE,ANI_SPP_NUM)
      do y_dim=1,MAX_Y_DIM
        do x_dim=1,MAX_X_DIM
          call check_and_reallocate_two(CELL(y_dim,x_dim)%SPP_GRAZED,ANI_SPP_NUM,PLA_SPP_NUM)
          call check_and_reallocate_two(CELL(y_dim,x_dim)%SPP_DETACH,ANI_SPP_NUM,PLA_SPP_NUM)
          call check_and_reallocate_int(CELL(y_dim,x_dim)%SS_PR_CLA,ANI_SPP_NUM)
        end do
      end do
      !}}}

      !}}}

    ! ------------------------
    ! # Animal competition factors {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      ! ## If competition switch is on
      if (COM_SW .eq. 1) then

        ! ### Competion can not exist when there is no animal difference and both fixed rate and stocking rate functions are off
        if(SPP_SW .eq. 0 .or. (FR_SW .eq. 0 .and. SD_SW .eq. 0)) then
          write(*,*) 'Error: SPP_SW and FR_SW or SD_SW should be turned on to have animal competition.'
          stop
        end if

        ! ### Read in competition factors
        read(GR_CON_SEA,*,iostat=ioerr) (ANI_COM_FAC(cur_ani), cur_ani=1,ANI_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Animal competition factors reading error'
          stop
        else
          write(ECHO_NUM,*) 'Animal competition exist, factors of species are: '
          write(ECHO_NUM,*) ANI_COM_FAC
        end if

      else

        ! ### When there is no competitions, the different species will get equal amount of resources
        ANI_COM_FAC(:)=1/ANI_SPP_NUM
        read(GR_CON_SEA,*)      ! skip this line

      end if
      !}}}

    ! ------------------------
    ! # Maximum and minimum management grazing amount modification {{{
    ! ------------------------

      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      ! ## Maximum amount of grazing management
      if (MAN_SW(2) .eq. 1) then
        read(GR_CON_SEA,*,iostat=ioerr) MAX_GR_AMT
        if (ioerr .ne. 0) then
          write(*,*) 'Maximum grazing amount configuration reading error'
          stop
        else
          write(ECHO_NUM,*) 'Grazing amount cannot exceed', MAX_GR_AMT
        end if

      else

        ! ### If maximum amount of grazing management switch is off, nothing changed
        read(GR_CON_SEA,*)        ! Skip this line

      end if

      ! ## Minimum amount of grazing management
      if (MAN_SW(3) .eq. 1) then
        read(GR_CON_SEA,*,iostat=ioerr) MIN_GR_AMT
        if (ioerr .ne. 0) then
          write(*,*) 'Minimum grazing amount configuration reading error'
          stop
        else
        write(ECHO_NUM,*) 'Grazing amount cannot less than', MIN_GR_AMT
        end if

      else

        ! ### If minimum amount of grazing management switch is off, minimum management grazing amount is zero. This variable is used for later demand modification
        MIN_GR_AMT=0
        read(GR_CON_SEA,*)        ! Skip this line

      end if
      !}}}

    ! ------------------------
    ! # Fixed rate {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      ! # Read in the grazing rate for each animal species
      if (FR_SW .eq. 1) then

      ! read(GR_CON_SEA,*)
      !
      ! FIX_GR_R(:)=temp_f

        read(GR_CON_SEA,*,iostat=ioerr)(FIX_GR_R(cur_ani), cur_ani=1,ANI_SPP_NUM)
        write(*,*) FIX_GR_R(:)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Fixed grazing rate reading error'
          stop
        else
          write(ECHO_NUM,*) 'Fixed grazing rate for each animal species are: '
          do cur_ani=1,ANI_SPP_NUM
            write(ECHO_NUM,*) FIX_GR_R(cur_ani)
          end do
        end if

      else

        read(GR_CON_SEA,*) ! Skip the line

      end if ! end FR_SW cheking }}}

    ! ------------------------
    ! # Stocking rate function {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (SD_SW .eq. 1) then

        ! ## If both stocking density switch and fixed rate switch are on, stop the model
        if (FR_SW .eq. 1) then
          write(*,*) 'Error: Fixed grazing rate and Stoking density cannot both be turned on.'
          stop
        end if

        ! For GI loop
        read(GR_CON_SEA,*)
        MAX_SD(:)=temp_f

        ! ## Read in maximum stoking density
        ! read(GR_CON_SEA,*,iostat=ioerr)(MAX_SD(cur_ani), cur_ani=1,ANI_SPP_NUM)
        ! if (ioerr .ne. 0 ) then 
        !   write(*,*) 'Maximum stocking density reading error'
        !   stop
        ! else
        !   write(ECHO_NUM,*) 'Maximum stocking density for each animal species are: '
        !   do cur_ani=1,ANI_SPP_NUM
        !     write(ECHO_NUM,*) MAX_SD(cur_ani)
        !   end do
        ! end if
        !
        ! write(*,*) MAX_SD(:)

        ! ## Read in minimum stoking density
        read(GR_CON_SEA,*,iostat=ioerr)(MIN_SD(cur_ani), cur_ani=1,ANI_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Minimum stocking density reading error'
          stop
        else
          write(ECHO_NUM,*) 'Minimum stocking density for each animal species are: '
          do cur_ani=1,ANI_SPP_NUM
            write(ECHO_NUM,*) MIN_SD(cur_ani)
          end do
        end if

        ! ## Read in maximum intake per animal
        read(GR_CON_SEA,*,iostat=ioerr)(MAX_INT(cur_ani), cur_ani=1,ANI_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Maximum animal intake reading error'
          stop
        else
          write(ECHO_NUM,*) 'Maximum animal intake for each animal species are: '
          do cur_ani=1,ANI_SPP_NUM
            write(ECHO_NUM,*) MAX_INT(cur_ani)
          end do
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if !end SD_SW checking }}}

    ! ------------------------
    ! # Detachment rate {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (DT_SW .eq. 1) then

        ! ## If Detachment is on while there is neither fixed rate or stocking density function, stop the model, because detachment is based on grazing rate
        if(FR_SW .eq. 0 .and. SD_SW .eq. 0) then
          write(*,*) 'Error: FR_SW or SD_SW must be turned on to have detachment effects.'
          stop
        end if

        read(GR_CON_SEA,*,iostat=ioerr)(DET_RATE(cur_ani), cur_ani=1,ANI_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Detachment rate reading error'
          stop
        else
          write(ECHO_NUM,*) 'Detachment rate for each animal species are: '
          do cur_ani=1,ANI_SPP_NUM
            write(ECHO_NUM,*) DET_RATE(cur_ani)
          end do
        end if
      else
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end DT_SW cheking }}}

    ! ------------------------
    ! # Soil compactness {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (SC_SW .eq. 1) then

        ! ## Stocking density function rate should be turned on to have soil compactness effects, becase soil compactness changes depends on stocking density
        if (SD_SW .eq. 0) then
          write(*,*) 'SD_SW must be turned on to have calculate soil compactness.'
          stop
        end if

        ! ## Read in variable A
        read(GR_CON_SEA,*,iostat=ioerr)(SC_VAR_A(cur_ani), cur_ani=1,ANI_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Soil compactness variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'Soil compactness variables A for each animal species are: '
          write(ECHO_NUM,*) SC_VAR_A
        end if

        ! ## Read in free soil compactness
        read(GR_CON_SEA,*,iostat=ioerr) SC_FREE
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Soil compactness variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'Soil compactness when stocking density is 0 is: '
          write(ECHO_NUM,*) SC_FREE
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end SC_SW cheking }}}

    ! ------------------------
    ! # LAI {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (LA_SW .eq. 1) then

        ! ## Allocate variables used in LAI calculation
        if(.not. allocated(ASLA))allocate(ASLA(PLA_SPP_NUM))
        if(.not. allocated(F_LA))allocate(F_LA(PLA_SPP_NUM))

        ! ## Read in average specific leaf area
        read(GR_CON_SEA,*,iostat=ioerr)(ASLA(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Average specific leaf area reading error'
          stop
        else
          write(ECHO_NUM,*) 'Average specific leaf area for each plant species are: '
          write(ECHO_NUM,*) ASLA
        end if

        ! ## Read in Fraction to lamina
        read(GR_CON_SEA,*,iostat=ioerr)(F_LA(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Growth fraction to lamina reading error'
          stop
        else
          write(ECHO_NUM,*) 'Growth fraction to lamina for each plant species are: '
          write(ECHO_NUM,*) F_LA
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end MR_SW cheking }}}

    ! ------------------------
    ! # Respiration rate {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (RS_SW .eq. 1) then

        ! ## Allocate variables
        if(.not. allocated(RES_RATE))allocate(RES_RATE(PLA_SPP_NUM))

        ! ## Read in respiration rate for each plant species each season
        read(GR_CON_SEA,*,iostat=ioerr)(RES_RATE(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Respiration rate reading error'
          stop
        else
          write(ECHO_NUM,*) 'Respiration rate for each plant species are: '
          write(ECHO_NUM,*) RES_RATE
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end RS_SW cheking }}}

    ! ------------------------
    ! # Nitrogen return {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      ! ## Read in nitrogen concentration
      if (any(NR_SW(:) .eq. 1) .or. AN_EF_SW(2) .eq. 1) then
        read(GR_CON_SEA,*,iostat=ioerr)(SPP_N_CON(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Nitrogen concentration reading error'
          stop
        else
          write(ECHO_NUM,*) 'Nitrogen concentration for each plant species are: '
          do cur_pla=1,PLA_SPP_NUM
            write(ECHO_NUM,*) SPP_N_CON(cur_pla)
          end do
        end if
      else
        read(GR_CON_SEA,*) ! Skip the line
      end if

      ! ## Any Nitrogen return switch would turn this on. Either from urine or feces or both.
      if (any(NR_SW(:) .eq. 1)) then

      ! ## Fixed rate and stocking density should be turned on.
        if(FR_SW .eq. 0 .and. SD_SW .eq. 0) then
          write(*,*) 'Error: FR_SW or SD_SW should be turned on to have N return.'
          stop
        end if

      ! ## Read in nitrogen return rate
        read(GR_CON_SEA,*,iostat=ioerr)(N_RET_RATE(cur_ani), cur_ani=1,ANI_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Nitrogen return rate reading error'
          stop
        else
          write(ECHO_NUM,*) 'Nitrogen return rate for each plant species are: '
          do cur_ani=1,ANI_SPP_NUM
            write(ECHO_NUM,*) N_RET_RATE(cur_ani)
          end do
        end if

      ! ## Read in plant C to N ratio
        read(GR_CON_SEA,*,iostat=ioerr)(SPP_CN(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Plant C to N ratio reading error'
          stop
        else
          write(ECHO_NUM,*) 'Plant C to N ratio for each plant species are: '
          do cur_pla=1,PLA_SPP_NUM
            write(ECHO_NUM,*) SPP_CN(cur_pla)
          end do
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end NR_SW cheking }}}

    ! ------------------------
    ! # Soil compactness effects on plant growth rate {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (SC_EF_SW .eq. 1 .and. SC_SW .eq. 1) then

        ! ## Allocate variables
        if(.not. allocated(SC_EF_VAR_A))allocate(SC_EF_VAR_A(PLA_SPP_NUM))
        if(.not. allocated(SC_EF_VAR_B))allocate(SC_EF_VAR_B(PLA_SPP_NUM))

        ! ## Read in variable A
        read(GR_CON_SEA,*,iostat=ioerr)(SC_EF_VAR_A(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Soil compactness - plant growth effect variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'Soil compactness - plant growth effect variables A for each plant species are: '
          write(ECHO_NUM,*) SC_EF_VAR_A
        end if

        ! ## Read in variable B
        read(GR_CON_SEA,*,iostat=ioerr)(SC_EF_VAR_B(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Soil compactness - plant growth effect variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'Soil compactness - plant growth effect variables B for each plant species are: '
          write(ECHO_NUM,*) SC_EF_VAR_B
        end if

      else if (SC_EF_SW .eq. 1 .and. SC_SW .eq. 0) then
        write(*,*) 'SC_SW should be turned on when using Soil compactness effects on plant growth rate'
        stop

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end SC_EF_SW cheking }}}

    ! ------------------------
    ! # Effects from LAI on plant photosysthesis {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (LA_EF_SW(1) .eq. 1) then

        ! ## Allocate variables
        if(.not. allocated(LA_PS_VAR_A))allocate(LA_PS_VAR_A(PLA_SPP_NUM))
        if(.not. allocated(LA_PS_VAR_B))allocate(LA_PS_VAR_B(PLA_SPP_NUM))

        ! ## Read in variable A
        read(GR_CON_SEA,*,iostat=ioerr)(LA_PS_VAR_A(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'LAI-photosysthesis effect variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'LAI-photosysthesis effect variables A for each plant species are: '
          write(ECHO_NUM,*) LA_PS_VAR_A
        end if

        ! ## Read in variable B
        read(GR_CON_SEA,*,iostat=ioerr)(LA_PS_VAR_B(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'LAI-photosysthesis effect variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'LAI-photosysthesis effect variables B for each plant species are: '
          write(ECHO_NUM,*) LA_PS_VAR_B
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end LA_EF_SW(1) cheking }}}

    ! ------------------------
    ! # Effects from LAI on plant rainfall interception {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (LA_EF_SW(2) .eq. 1) then

        ! ## Allocate variables
        if(.not. allocated(LA_RI_VAR_A))allocate(LA_RI_VAR_A(PLA_SPP_NUM))

        ! ## Read in variable A
        read(GR_CON_SEA,*,iostat=ioerr)(LA_RI_VAR_A(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'LAI-rainfall interception effect variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'LAI-rainfall interception effect variables A for each plant species are: '
          write(ECHO_NUM,*) LA_RI_VAR_A
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end LA_EF_SW(2) cheking }}}

    ! ! ------------------------
    ! ! # Effects from LAI on plant transpiration {{{
    ! ! ------------------------
    !   read(GR_CON_SEA,*)
    !   read(GR_CON_SEA,*)
    !   read(GR_CON_SEA,*)
    !
    !   if (LA_EF_SW(4) .eq. 1) then
    !
    !     ! ## Allocate variables
    !     if(.not. allocated(LA_TP_VAR_A))allocate(LA_TP_VAR_A(PLA_SPP_NUM))
    !
    !     ! ## Read in variable A
    !     read(GR_CON_SEA,*,iostat=ioerr)(LA_TP_VAR_A(cur_pla), cur_pla=1,PLA_SPP_NUM)
    !     if (ioerr .ne. 0 ) then 
    !       write(*,*) 'LAI-transpiration effect variables reading error'
    !       stop
    !     else
    !       write(ECHO_NUM,*) 'LAI-transpiration effect variables A for each plant species are: '
    !       write(ECHO_NUM,*) LA_TP_VAR_A
    !     end if
    !
    !   else
    !     read(GR_CON_SEA,*) ! Skip the line
    !
    !   end if ! end LA_EF_SW(4) cheking }}}
 
    ! ------------------------
    ! # N uptake {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (AN_EF_SW(1) .eq. 1) then

        ! ## Allocate variables 
        if(.not. allocated(AN_NU_VAR_A))allocate(AN_NU_VAR_A(PLA_SPP_NUM))
        if(.not. allocated(AN_NU_VAR_B))allocate(AN_NU_VAR_B(PLA_SPP_NUM))

        ! ## Read in variable A
        read(GR_CON_SEA,*,iostat=ioerr)(AN_NU_VAR_A(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'N uptake variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'N uptake variables A for each plant species are: '
          write(ECHO_NUM,*) AN_NU_VAR_A
        end if

        ! ## Read in variable B
        read(GR_CON_SEA,*,iostat=ioerr)(AN_NU_VAR_B(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'N uptake variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'N uptake variables B for each plant species are: '
          write(ECHO_NUM,*) AN_NU_VAR_B
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end AN_EF_SW(1) cheking }}}

    ! ------------------------
    ! # C conversion {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (AN_EF_SW(2) .eq. 1) then

        ! ## Allocate variables 
        if(.not. allocated(AN_CC_VAR_A))allocate(AN_CC_VAR_A(PLA_SPP_NUM))
        if(.not. allocated(AN_CC_VAR_B))allocate(AN_CC_VAR_B(PLA_SPP_NUM))

        ! ## Read in variable A
        read(GR_CON_SEA,*,iostat=ioerr)(AN_CC_VAR_A(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'C conversion variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'C conversion variables A for each plant species are: '
          write(ECHO_NUM,*) AN_CC_VAR_A
        end if

        ! ## Read in variable B
        read(GR_CON_SEA,*,iostat=ioerr)(AN_CC_VAR_B(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'C conversion variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'C conversion variables B for each plant species are: '
          write(ECHO_NUM,*) AN_CC_VAR_B
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end AN_EF_SW(2) cheking

      ! Read in potential conversion rate. This variable should be read regardless of the switch
      if(.not. allocated(POT_CC))allocate(POT_CC(PLA_SPP_NUM))

      read(GR_CON_SEA,*,iostat=ioerr)(POT_CC(cur_pla), cur_pla=1,PLA_SPP_NUM)

      if (ioerr .ne. 0 ) then 
        write(*,*) 'Potential C conversion rate reading error'
        stop
      else
        write(ECHO_NUM,*) 'Potential C conversion rate is: '
        write(ECHO_NUM,*) POT_CC
      end if
      ! }}}

    ! ------------------------
    ! # Root to shoot ratio {{{
    ! ------------------------
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)
      read(GR_CON_SEA,*)

      if (AN_EF_SW(3) .eq. 1) then

        ! ## Allocate variables 
        if(.not. allocated(AN_RT_VAR_A))allocate(AN_RT_VAR_A(PLA_SPP_NUM))
        if(.not. allocated(AN_RT_VAR_B))allocate(AN_RT_VAR_B(PLA_SPP_NUM))

        ! ## Read in variable A
        read(GR_CON_SEA,*,iostat=ioerr)(AN_RT_VAR_A(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Root to shoot ratio variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'Root to shoot ratio variables A for each plant species are: '
          write(ECHO_NUM,*) AN_RT_VAR_A
        end if

        ! ## Read in variable B
        read(GR_CON_SEA,*,iostat=ioerr)(AN_RT_VAR_B(cur_pla), cur_pla=1,PLA_SPP_NUM)
        if (ioerr .ne. 0 ) then 
          write(*,*) 'Root to shoot ratio variables reading error'
          stop
        else
          write(ECHO_NUM,*) 'Root to shoot ratio variables B for each plant species are: '
          write(ECHO_NUM,*) AN_RT_VAR_B
        end if

      else
        read(GR_CON_SEA,*) ! Skip the line
        read(GR_CON_SEA,*) ! Skip the line

      end if ! end AN_EF_SW(3) cheking }}}

end subroutine
