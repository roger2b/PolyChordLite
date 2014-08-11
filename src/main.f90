!> This is the main driving routine of the nested sampling algorithm
program main

    ! ~~~~~~~ Loaded Modules ~~~~~~~

    use nested_sampling_module, only: NestedSampling
    use model_module,           only: model, initialise_model
    use settings_module,        only: program_settings
    use random_module,          only: initialise_random, deinitialise_random

    use chordal_module,      only: ChordalSampling
    use test_sampler_module, only: BruteForceSampling,SphericalCenterSampling,CubicCenterSampling
    use evidence_module
    use example_likelihoods
    use feedback_module

    ! ~~~~~~~ Local Variable Declaration ~~~~~~~
    implicit none

    type(program_settings) :: settings  ! The program settings 
    type(model)            :: M         ! The model details




    ! ======= (1) Initialisation =======
    ! We need to initialise:
    ! a) random number generator
    ! b) model
    ! c) program settings

    ! ------- (1a) Initialise random number generator -------
    ! Initialise the random number generator with the system time
    ! (Provide an argument to this if you want to set a specific seed
    ! leave argumentless if you want to use the system time)
    call initialise_random()


    ! ------- (1b) Initialise the model -------
    ! Assign the likelihood function
    ! This one is a basic gaussian log likelihood
    M%loglikelihood => gaussian_loglikelihood

    M%nDims=30                 ! Dimensionality of the space
    M%nDerived = 1             ! Assign the number of derived parameters

    ! set priors as uniform with all
    M%uniform_num = M%nDims
    allocate( M%uniform_params(M%uniform_num,2) )
    M%uniform_params(:,1) = 0
    M%uniform_params(:,2) = 1
    M%uniform_index = 1



    
    call initialise_model(M)   ! Configure the rest of the model


    ! ------- (1c) Initialise the program settings -------
    settings%nlive                =  100*M%nDims             !number of live points
    settings%sampler              => ChordalSampling         !Sampler choice
    settings%evidence_calculator  => KeetonEvidence          !evidence calculator
    settings%feedback             =  1                       !degree of feedback
    settings%precision_criterion  =  1d-5                    !degree of precision in answer
    settings%max_ndead            =  -1                      !maximum number of samples
    settings%save_dead            =  .false.                 !don't save any dead points

    settings%num_chords           =  20                     !number of chords to draw        


    ! ======= (2) Perform Nested Sampling =======
    ! Call the nested sampling algorithm on our chosen likelihood and priors
    call write_opening_statement(M,settings)
    call NestedSampling(M,settings)



    ! ======= (3) De-initialise =======
    ! De-initialise the random number generator 
    call deinitialise_random()



end program main
