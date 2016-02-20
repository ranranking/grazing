subroutine grazing

  use parameter_var
  use structure
  implicit none

! # Spatial dimension loop
do y_dim=1,MAX_Y_DIM
do x_dim=1,MAX_X_DIM

! # When global grazing switch is on
if (GR_SW .eq. 1) then

! ------------------------
! ## Calculate actual grazed amount in each cell
! ------------------------

  ! ### First, loop for animal species
  do cur_ani=1,ANI_SPP_NUM

    ! ### Second, loop for site preference classes
    do cur_cla=1,SITE_PREF(cur_ani)%SS_CLA_NUM

      ! ### Then, loop for plant species
      do cur_pla=1,PLA_SPP_NUM

      ! #### LAI selection. Calculate actual diet fraction which is affected by LAI if the switch is on.
        if(DS_SW(2) .eq. 1) then
          LAI_FAC=(CELL(y_dim,x_dim)%SPP_LAI(cur_pla)**3)/((CELL(y_dim,x_dim)%SPP_LAI(cur_pla)**3)+1)
        else
          LAI_FAC=1
        end if ! end LAI switch cheking

        ! ##### Check which class the cell is in for current animal species and calculate cell level grazed amount for each plant species, animal species and site preference class levelfor each plant species, animal species and site preference class level.
        if(CELL(y_dim,x_dim)%SS_PR_CLA(cur_ani) .eq. cur_cla) then

          ! @# Dominator check
          if (SITE_PREF(cur_ani)%SPP_AV_BIO(cur_cla,cur_pla) .ge. 0) then 
            CELL(y_dim,x_dim)%SPP_GRAZED(cur_ani,cur_pla)=SITE_PREF(cur_ani)%SPP_FORAGE(cur_cla,cur_pla)&
                               *CELL(y_dim,x_dim)%AV_BIO_SPP(cur_pla)/SITE_PREF(cur_ani)%SPP_AV_BIO(cur_cla,cur_pla)&
                               *LAI_FAC
          else
            CELL(y_dim,x_dim)%SPP_GRAZED(cur_ani,cur_pla)=0
          end if    ! End dominator check


          ! ##### Nitrogen concentration modification when the switch is on
          if(DS_SW(3) .eq. 1 .and. CELL(y_dim,x_dim)%SPP_N_CON(cur_pla) .le. 0.0104) then
            CELL(y_dim,x_dim)%SPP_GRAZED(cur_ani,cur_pla)=CELL(y_dim,x_dim)%SPP_GRAZED(cur_ani,cur_pla)*0.964&
                                        *CELL(y_dim,x_dim)%SPP_N_CON(cur_pla)+1.5
          end if ! end nitrogen concentration checking

        end if ! end cell preference cheking

      end do ! end plant looping
    end do ! end site preference class checking
  end do ! end animal species checking

! ------------------------
! # First stage
! ------------------------

  do cur_pla=1,PLA_SPP_NUM

  ! ## Defoliation effect
    if (DF_SW .eq. 1) then

      CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)=CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)&
                                              -sum(CELL(y_dim,x_dim)%SPP_GRAZED(:,cur_pla))

      if (CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla) .le. 0) then
        CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)=0
      end if

    end if

  ! ## Detachment
    if (DT_SW .eq. 1) then
      do cur_ani=1,ANI_SPP_NUM
        CELL(y_dim,x_dim)%SPP_DETACH(cur_ani,cur_pla)=CELL(y_dim,x_dim)%SPP_GRAZED(cur_ani,cur_pla)&
                                                      *DET_RATE(cur_ani)
      end do

      CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)=CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)&
                                              -sum(CELL(y_dim,x_dim)%SPP_DETACH(:,cur_pla))

      if (CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla) .le. 0) then
        CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)=0
      end if

    end if

  ! ## Mortality rate
    if (MR_SW .eq. 1) then
      CELL(y_dim,x_dim)%SPP_MOR(cur_pla)=CELL(y_dim,x_dim)%SPP_MOR(cur_pla)&
                                    *MR_VAR_A(cur_pla)*sum(CELL(y_dim,x_dim)%SPP_GRAZED(:,cur_pla))&
                                    +MR_VAR_B(cur_pla)*sum(CELL(y_dim,x_dim)%SPP_GRAZED(:,cur_pla))&
                                    *CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)/CELLAREA
    end if

  end do ! Stop looping for plant species


  ! ## Soil compactness
  CELL(y_dim,x_dim)%SOIL_DCOM=0
  if (SC_SW .eq. 1) then
    do cur_ani=1,ANI_SPP_NUM
      CELL(y_dim,x_dim)%SOIL_DCOM=CELL(y_dim,x_dim)%SOIL_DCOM+(SC_VAR_A(cur_ani)*CELL(y_dim,x_dim)%SD(cur_ani)&
                                                           /(SC_VAR_B(cur_ani)+CELL(y_dim,x_dim)%SD(cur_ani)))
    end do
  else
    CELL(y_dim,x_dim)%SOIL_DCOM=0
  end if
  CELL(y_dim,x_dim)%SOIL_COM=SC_FREE+CELL(y_dim,x_dim)%SOIL_DCOM

else  ! When there is no grazing
  CELL(y_dim,x_dim)%SOIL_DCOM=0

end if ! end checking GR_SW

! ------------------------
! # Second stage
! ------------------------

  do cur_pla=1,PLA_SPP_NUM

  ! ## LAI
    if (LA_SW .eq. 1) then
      CELL(y_dim,x_dim)%SPP_LAI(cur_pla)=10*(128-62*exp(-10.2*CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)))&
                                                      *CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)/CELLAREA
    else
      CELL(y_dim,x_dim)%SPP_LAI(cur_pla)=1 ! Default values
    end if

  ! ## Respiration rate
    if (RS_SW .eq. 1) then
       CELL(y_dim,x_dim)%SPP_RES(cur_pla)=RES_RATE(cur_pla)*CELL(y_dim,x_dim)%TOT_BIO_SPP(cur_pla)
     else
       CELL(y_dim,x_dim)%SPP_RES(cur_pla)=1
    end if

  ! ## Available N
    do cur_ani=1,ANI_SPP_NUM

      ! ### 0) Total N output from animal
      if (any(NR_SW(:) .eq. 1)) then
        N_RET=N_RET_RATE(cur_ani)*CELL(y_dim,x_dim)%SPP_GRAZED(cur_ani,cur_pla)&
                                                   *CELL(y_dim,x_dim)%SPP_N_CON(cur_pla)
      end if

      ! ### 1) From urine
      if (NR_SW(1) .eq. 1) then
        CELL(y_dim,x_dim)%AN_POOL=CELL(y_dim,x_dim)%AN_POOL+N_RET&
                                                *(0.7*(CELL(y_dim,x_dim)%SPP_N_CON(cur_pla)&
                                                /cell(y_dim,x_dim)%SPP_C_CON(cur_pla)-12)/13)
      end if

      ! ###  2) From feces
      if (NR_SW(2) .eq. 1) then
        CELL(y_dim,x_dim)%LIT_N=CELL(y_dim,x_dim)%LIT_N+N_RET&
                                                *(1-0.7*(CELL(y_dim,x_dim)%SPP_N_CON(cur_pla)&
                                                /cell(y_dim,x_dim)%SPP_C_CON(cur_pla)-12)/13)
      end if

    end do ! end looping of animal species

  ! Litter pool
    if (LP_SW .eq. 1) then
      CELL(y_dim,x_dim)%LIT_POOL=CELL(y_dim,x_dim)%LIT_POOL+sum(CELL(y_dim,x_dim)%SPP_DETACH(:,cur_pla))
    end if


  end do ! end looping for plant species

! ------------------------
! Third stage
! ------------------------

  do cur_pla=1,PLA_SPP_NUM
  ! From Soil compactness

    if (SC_EF_SW .eq. 1) then
      CELL(y_dim,x_dim)%SPP_GRO(cur_pla)=CELL(y_dim,x_dim)%SPP_GRO(cur_pla)*(1+SC_EF_VAR_A(cur_pla)&
                                                  *CELL(y_dim,x_dim)%SOIL_DCOM/0.15)!&
                                                  ! -SC_EF_VAR_B(cur_ani)
    end if

  ! From LAI
    ! 1) Change in photosysthesis
    if (LA_EF_SW(1) .eq. 1) then
      CELL(y_dim,x_dim)%SPP_PS(cur_pla)=LA_PS_VAR_A(cur_pla)*CELL(y_dim,x_dim)%SPP_LAI(cur_pla)&
                                          /(LA_PS_VAR_B(cur_pla)+CELL(y_dim,x_dim)%SPP_LAI(cur_pla))
    else
      CELL(y_dim,x_dim)%SPP_PS(cur_pla)=1
    end if

    ! 2) Change in rainfall interception

    if (LA_EF_SW(2) .eq. 1) then
      CELL(y_dim,x_dim)%SPP_RI(cur_pla)=1-exp(-LA_RI_VAR_A(cur_pla)*CELL(y_dim,x_dim)%SPP_LAI(cur_pla))
    else
      CELL(y_dim,x_dim)%SPP_RI(cur_pla)=1
    end if

  end do ! end looping for plant species

    ! 3) Chang in evapotranspiration
    ! 3.0) Potential evapotranspiration
    if(LA_EF_SW(3) .eq. 1 .or. LA_EF_SW(4) .eq. 1) then
      CELL(y_dim,x_dim)%POT_ETP=0.128*(SOLA_RAD*(1-(0.23*(1-exp(-0.000029&
                                        *(CELL(y_dim,x_dim)%TOT_BIOMASS+CELL(y_dim,x_dim)%LIT_POOL))&
                                        +SOIL_ALB*0.24))/58.3))*((5304/(AVG_TEMP**2))*exp(21.25-(5304/AVG_TEMP))&
                                        /((5304/(AVG_TEMP**2))*exp(21.25-(5304/AVG_TEMP))+0.68))
    end if

    ! 3.1) Potential soil evaporation
    if(LA_EF_SW(3) .eq. 1) then
      CELL(y_dim,x_dim)%POT_EVP=CELL(y_dim,x_dim)%POT_ETP*exp(-0.4*sum(CELL(y_dim,x_dim)%SPP_LAI(:)/PLA_SPP_NUM))
    else
      CELL(y_dim,x_dim)%POT_EVP=1
    end if

  do cur_pla=1,PLA_SPP_NUM

    ! 3.2) Potential transpiration
    if(LA_EF_SW(4) .eq. 1) then
      if(CELL(y_dim,x_dim)%SPP_LAI(cur_pla) .le. 3) then
        CELL(y_dim,x_dim)%SPP_TRP(cur_pla)=CELL(y_dim,x_dim)%POT_ETP*CELL(y_dim,x_dim)%SPP_LAI(cur_pla)/3
      else
        CELL(y_dim,x_dim)%SPP_TRP(cur_pla)=CELL(y_dim,x_dim)%POT_ETP
      end if
    else
      CELL(y_dim,x_dim)%SPP_TRP(cur_pla)=1
    end if

    ! 4) Change in available light for other species
    if(LA_EF_SW(5) .eq. 1) then
    end if

  ! Form available N
    ! 1) Change in N uptake
    if (AN_EF_SW(1) .eq. 1) then
      CELL(y_dim,x_dim)%SPP_NU(cur_pla)=AN_NU_VAR_A(cur_pla)*CELL(y_dim,x_dim)%AN_POOL&
                                        /(AN_NU_VAR_B(cur_pla)+CELL(y_dim,x_dim)%AN_POOL)
    else
      CELL(y_dim,x_dim)%SPP_NU(cur_pla)=1
    end if

    ! 2) Change in carbon conversion
    if (AN_EF_SW(2) .eq. 1) then
      CELL(y_dim,x_dim)%SPP_CC(cur_pla)=AN_CC_VAR_A(cur_pla)*CELL(y_dim,x_dim)%SPP_N_CON(cur_pla)&
                                        +AN_CC_VAR_B(cur_pla)
    else
      CELL(y_dim,x_dim)%SPP_CC(cur_pla)=POT_CC(cur_pla)
    end if

    ! 3) Change in root to shoot ratio
    if (AN_EF_SW(3) .eq. 1) then
      CELL(y_dim,x_dim)%SPP_RT(cur_pla)=AN_RT_VAR_A(cur_pla)/(1+AN_RT_VAR_B(cur_pla)*(CELL(y_dim,x_dim)%SPP_CC(cur_pla)&
                                                                  /POT_CC(cur_pla)))
    else
      CELL(y_dim,x_dim)%SPP_RT(cur_pla)=1
    end if

    ! 4) root to shoot ratio with C and N relationship
    end do ! end looping plant species

end do  ! end looping for x
end do ! end looping for y

end subroutine grazing