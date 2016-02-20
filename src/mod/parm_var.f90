module parameter_var

  !--------- -------- --------- --------- --------- --------- --------- --------- -----
  ! For general model use
  !--------- -------- --------- --------- --------- --------- --------- --------- -----

  ! Global parameters and variables
  integer, parameter                   :: rn = KIND(0.0d0)                            ! Precision of real numbers
  integer, parameter                   :: is = SELECTED_INT_KIND(1)                   ! Data type of bytecode
  integer                              :: MAX_X_DIM, MAX_Y_DIM                        ! Maximum dimension of the world
  real                                 :: CELLAREA                                    ! Cell area
  integer                              :: seed                                        ! seed multipliers, used for random number generation
  character(100)                       :: CWD                                         ! current working directory
  character(40)                        :: SIM_CON_NAME='/conf/sim_config.gr'        ! general configuration file
  integer, parameter                   :: SIM_CON_NUM=99                              ! general config device number
  character(30)                        :: OUTPUT_DIR                                  ! output file name
  integer, parameter                   :: OUTPUT_NUM=100                              ! output device number
  character(30)                        :: ECHO_NAME='/.echo.gr'                        ! echo file name
  integer, parameter                   :: ECHO_NUM=300                                ! echo file device number
  integer                              :: SW_NUM                                      ! Used to store number of switches is there are multiple switches
  integer                              :: SWITCH=200                                  ! Device switchice number for grazing process switch file
  character(50)                        :: SWITCH_FILE='/conf/switches.gr'           ! Grazing process file name
  integer                              :: AY_CON=201
  character(50)                        :: AY_CON_F='/conf/all_year_conf.gr'
  integer                              :: GR_CON_SEA=150                              ! temp function device number
  integer                              :: DS_CON=151
  integer                              :: SS_CON=152
  character(30)                        :: PRE_DIR_GC='/conf/graz_conf_'             ! Since there would be season folders, this piece needs to be separated for now
  character(30)                        :: PRE_DIR_DS='/conf/diet_conf_'
  character(30)                        :: PRE_DIR_SS='/conf/site_conf_'
  logical                              :: isopen                                      ! Check whether a file is opened
  integer                              :: ioerr                                       ! i/o error indicator
  integer                              :: direrr                                      ! directory error indicator
  integer                              :: x_dim, y_dim
  integer                              :: lower_x, lower_y, upper_x, upper_y
  real                                 :: cellsize
  integer                              :: year
  integer                              :: month
  integer                              :: day
  integer                              :: start_yr
  integer                              :: end_yr
  character(10)                        :: SEASON                                 ! Used to store directories for each season

  !--------- -------- --------- --------- --------- --------- --------- --------- -----
  ! For grazing switches
  !--------- -------- --------- --------- --------- --------- --------- --------- -----

  ! For Grazing process switch and relative variables
  integer                              :: SPP_SW                  ! Switches for species difference
  integer                              :: COM_SW                  ! Switches for species competition
  integer                              :: SEA_SW                  ! Switch for seasonal difference
  integer, dimension(:), allocatable   :: MAN_SW                  ! Switches for management differece, 2 dimensions
  integer                              :: FR_SW                   ! Switch for fixed grazing rate
  integer                              :: SD_SW                   ! Switch for grazing as function of stocking rate
  integer                              :: UN_SW                   ! Switch for unavailable plant biomass
  integer, dimension(:), allocatable   :: DS_SW                   ! Switches for diet selection, 3 dimensions
  integer, dimension(:), allocatable   :: SS_SW                   ! Switches for site selection, 6 demensions


  ! For first stage effects
  integer                              :: DF_SW                   ! Switch for defoliation
  integer                              :: DT_SW                   ! Switch for detachment
  integer                              :: MR_SW                   ! Switch for mortality rate
  integer                              :: SC_SW                   ! Switch for grazing effects on the soil compactness

  ! For second stage effects
  integer                              :: LA_SW                   ! Switch for LAI effect
  integer                              :: RS_SW                   ! Switch for respiration effect
  integer, dimension(:), allocatable   :: NR_SW                   ! Switch for nitrogen return
  integer                              :: LP_SW                   ! Switch for litter pool effect

  ! For third stage effects
  integer                              :: SC_EF_SW                ! Switch for soil compactness effect
  integer, dimension(:), allocatable   :: LA_EF_SW                ! Switch for LAI effect
  integer, dimension(:), allocatable   :: AN_EF_SW                ! Switch for available N effects

	! For If Effects
	integer                              :: IF_EFF_SW               ! Swtich for If Effects

  !--------- -------- --------- --------- --------- --------- --------- --------- -----
  ! For grazing configuration
  !--------- -------- --------- --------- --------- --------- --------- --------- -----

  ! For species difference
  integer                              :: ANI_SPP_NUM             ! Number of animal species
  integer                              :: PLA_SPP_NUM             ! Number of plant species
  integer                              :: cur_ani                 ! Current animal species, used for looping
  integer                              :: cur_pla                 ! Current plant species, used for looping

  ! For seasonal difference
  integer                              :: SEA_NUM                 ! Number of seasons
  integer                              :: SPCP_SW                 ! Switch for whether to read user specified check points
  integer, dimension(:), allocatable   :: SEA_CP                  ! Used to store seasonal check points for each cell

  integer                              :: SEA_CH_SW               ! Used to turn seasonal change on and off, used to determine whether season has changed. Spatial demensional
  integer                              :: SEA_TEMP                ! Used to for seasonal change procedure. Spatial demensional

  ! Management configurations
  integer, dimension(:), allocatable   :: RO_CP                   ! Used to store rotation period check points
  integer                              :: RO_NUM                  ! Rotation period number
  integer, dimension(:), allocatable   :: MAN_CP                  ! Used to store management cycle check points
  real                                 :: MAX_GR_AMT              ! Maximum amount of grazing
  real                                 :: MIN_GR_AMT              ! Minimum amount of grazing

  ! For diet selection
  real, dimension(:), allocatable      :: UAV_RATE                ! Available biomass rate for each plant species
  integer, dimension(:,:), allocatable :: P_INDEX                 ! Preference index array for prefered plant species each animal species
  integer, dimension(:,:), allocatable :: L_INDEX                 ! Preference index array for less prefered plant species each animal species
  integer, dimension(:,:), allocatable :: U_INDEX                 ! Preference index array for unprefered plant species each animal species
  real                                 :: LAI_FAC                 ! LAI selection factor
  real                                 :: NIT_FAC                 ! Nitrogen concentration factor

  ! For site selection
  type SITE_SELECTION

    integer                             :: AB_CLA_NUM               ! Abundance selection class number
    real, dimension(:),   allocatable   :: AB_CP                    ! Abundance check points
    integer                             :: SL_CLA_NUM               ! Slope selection class number
    real, dimension(:),   allocatable   :: SL_CP                    ! Slope check points
    integer                             :: WA_CLA_NUM               ! Water resource selection class number
    real, dimension(:),   allocatable   :: WA_CP                    ! Water resource check points
    integer                             :: SN_CLA_NUM               ! Snow cover selection class number
    real, dimension(:),   allocatable   :: SN_CP                    ! Snow cover check points
    integer                             :: SS_CLA_NUM               ! Total site selection class number
    real, dimension(:),   allocatable   :: SS_CP                    ! Total site selection check points
    real, dimension(:,:), allocatable   :: SPP_AV_BIO               ! Class avaiable plant biomass for each plant species
    real, dimension(:),   allocatable   :: TOT_AV_BIO               ! Total class available plant biomass

    real, dimension(:,:), allocatable   :: DIET_FRAC                ! Preference fraction for Prefered plant species each site class each animal species
    real, dimension(:),   allocatable   :: D_DMD                    ! Class daily demand

    real, dimension(:,:), allocatable   :: SPP_FORAGE               ! Amount of forage each plant species in each class

  end type SITE_SELECTION
  type(SITE_SELECTION), dimension(:), allocatable  ::  SITE_PREF  ! Site preference for each animal species

  integer                             ::  cur_cla                 ! Current site class, used for class looping
  real                                ::  SUB_FRAC                ! Used for subtraction in Less prefered plant fraction calculation
  real                                ::  TEMP_BIO                ! Used in less prefered plant fraction, species percentage in Less prefered plant class

  !--------- -------- --------- --------- --------- --------- --------- --------- -----
  ! For grazing function variables
  !--------- -------- --------- --------- --------- --------- --------- --------- -----

  ! Global grazing switch
  integer                             :: GR_SW                    ! Global grazing switch, used to determine global grazing

  ! Animal competition
  real, dimension(:), allocatable     :: ANI_COM_FAC              ! Animal competition factor
  real, dimension(:), allocatable     :: ANI_AV_BIO               ! Global available plant biomass for each animal species used for stocking density calculation

  ! For fixed grazing rate
  real, dimension(:), allocatable     :: FIX_GR_R                 ! Fixed grazing rate for each animal species

  ! For stocking density function
  real, dimension(:), allocatable     :: MAX_SD                   ! Maximum stocking density
  real, dimension(:), allocatable     :: MIN_SD                   ! Minimum stocking density
  real, dimension(:), allocatable     :: SPP_SD                   ! Global stoking density for each animal species
  real                                :: TOT_SD                   ! Global total stocking density
  integer, dimension(:), allocatable  :: ANI_NUM_SPP              ! Global animal number for each species
  integer                             :: TOT_ANI_NUM              ! Global total animal number
  real, dimension(:), allocatable     :: MAX_INT                  ! Maximum intake per animal for each animal species
  real, dimension(:), allocatable     :: TOT_DMD                  ! Global total intake from each animal species

  ! For trampling and detachment
  real, dimension(:), allocatable     :: DET_RATE                 ! Detachment rate for each animal species

  ! For soil compactness calculation
  real, dimension(:), allocatable     :: SC_VAR_A                 ! First variable used for calculating soil compactness change from animal stoking density
  real, dimension(:), allocatable     :: SC_VAR_B                 ! Second variable used for calculating soil compactness change from animal stoking density
  real                                :: SC_FREE                  ! Soil compactness when there stocking density is 0

  ! For plant mortality effect calculation
  real, dimension(:), allocatable     :: MR_VAR_A
  real, dimension(:), allocatable     :: MR_VAR_B

  ! For nitrogen return
  real, dimension(:), allocatable     :: N_RET_RATE               ! Nitrogen return rate of each animal species
  real                                :: N_RET                    ! Nitrogen return from each animal species, temporary variable

  ! For soil compactness effects on plant growth rate
  real, dimension(:), allocatable     :: SC_EF_VAR_A              ! First variable used for calculating soil compactness effects on plant growth rate for each plant species
  real, dimension(:), allocatable     :: SC_EF_VAR_B              ! Second variable used for calculating soil compactness effects on plant growth rate for each plant species

  ! For LAI effects on photosynthesis
  real, dimension(:), allocatable     :: LA_PS_VAR_A              ! First variable used for calculating LAI effects on photosynthesis for each plant species
  real, dimension(:), allocatable     :: LA_PS_VAR_B              ! Second variable used for calculating LAI effects on photosynthesis for each plant species

  ! For LAI effects on rainfall interception
  real, dimension(:), allocatable     :: LA_RI_VAR_A              ! First variable used for calculating LAI effects on rainfall interception for each plant species

  ! For LAI effects on plant transpiration
  real, dimension(:), allocatable     :: LA_TP_VAR_A              ! First variable used for calculating LAI effects on plant transpiration for each plant species

  ! For available nitrogen effects on N uptake
  real, dimension(:), allocatable     :: AN_NU_VAR_A              ! First variable used for calculating available N effects on photosynthesis for each plant species
  real, dimension(:), allocatable     :: AN_NU_VAR_B              ! Second variable used for calculating available N effects on photosynthesis for each plant species

  ! For available nitrogen effects on C conversion
  real, dimension(:), allocatable     :: AN_CC_VAR_A              ! First variable used for calculating plant N concentration on Cconversion for each plant species
  real, dimension(:), allocatable     :: AN_CC_VAR_B              ! Second variable used for calculating plant N concentration on Cconversion for each plant species
  real, dimension(:), allocatable     :: POT_CC                   ! Second variable used for calculating plant N concentration on Cconversion for each plant species

  ! For available nitrogen effects on photosynthesis
  real, dimension(:), allocatable     :: AN_RT_VAR_A              ! First variable used for calculating root to shoot ratio for each plant species
  real, dimension(:), allocatable     :: AN_RT_VAR_B              ! Second variable used for calculating root to shoot ratio for each plant species

end module parameter_var

