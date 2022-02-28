using Scheduling, Scheduling.Objectives, Test

@testset "Types" begin
    @testset "Job" begin
        # Test a job constructor
        J = Job("I love scheduling")
        @test typeof(J) == Job &&
              typeof(J.params) == ClassicalJobParams &&
              J.params.p == 1 &&
              J.name == "I love scheduling"

        J = Job("I love scheduling",
                ClassicalJobParams(p = 3, w = 10, r = 2, d = 7, D = 8))
        @test typeof(J) == Job &&
              typeof(J.params) == ClassicalJobParams &&
              J.params.p == 3 &&
              J.params.w == 10 &&
              J.params.r == 2 &&
              J.params.d == 7 &&
              J.params.D == 8 &&
              J.name == "I love scheduling"

        J = Job("I love scheduling",
                ClassicalJobParams(p = 3//2, w = 10//3, r = 2//3, d = 7//2, D = 8//2))
        @test typeof(J) == Job &&
              typeof(J.params) == ClassicalJobParams &&
              J.params.p == 3//2 &&
              J.params.w == 10//3 &&
              J.params.r == 2//3 &&
              J.params.d == 7//2 &&
              J.params.D == 8//2 &&
              J.name == "I love scheduling"

        # The following tests whether an exception is thrown if r + p > D
        @test_throws Exception Job("J",
                     ClassicalJobParams(r = 5, p = 100, D = 104))
    end

    @testset "Jobs" begin
        # Test a general constructor
        J = Jobs()
        @test typeof(J) == Vector{Job} && length(J) == 0

        # Test a constructor for identical jobs
        J = Jobs(100)
        @test typeof(J) == Vector{Job} &&
              length(J) == 100 &&
              all(typeof(job.params) == ClassicalJobParams for job in J) &&
              all(job.params.p == 1 for job in J)

         # Test a constructor for an array of integers
         A = [1, 5, 2, 3, 4, 1, 7, 8, 12, 18, 7, 3]
         J = Jobs(A)
         @test typeof(J) == Vector{Job} &&
               length(J) == 12 &&
               all(typeof(job.params) == ClassicalJobParams for job in J) &&
               all(J[i].params.p == A[i] for i in 1:length(J))

         # Test a constructor for an array of rationals
         A = [1//2, 5//2, 2//3, 3//4, 4//1, 1//6, 7//9, 8//12, 12//6, 18//3, 7//4, 3//2]
         J = Jobs(A)
         @test typeof(J) == Vector{Job} &&
               length(J) == 12 &&
               all(typeof(job.params) == ClassicalJobParams for job in J) &&
               all(J[i].params.p == A[i] for i in 1:length(J))

         # The following test whether an exception is thrown if p < 0
         @test_throws Exception Jobs([1, 2, -1])
         @test_throws Exception Jobs([1//2, 2//1, -1//2])
    end

    @testset "Machine" begin
        # Test a machine constructor
        M = Machine("I love scheduling")
        @test typeof(M) == Machine &&
              typeof(M.params) == ClassicalMachineParams &&
              M.params.s == 1 &&
              M.name == "I love scheduling"

        M = Machine("I love scheduling", ClassicalMachineParams(s = 3))
        @test typeof(M) == Machine &&
              typeof(M.params) == ClassicalMachineParams &&
              M.params.s == 3 &&
              M.name == "I love scheduling"

        M = Machine("I love scheduling", ClassicalMachineParams(s = 3//2))
        @test typeof(M) == Machine &&
              typeof(M.params) == ClassicalMachineParams &&
              M.params.s == 3//2 &&
              M.name == "I love scheduling"

        # The following tests whether an exception is thrown if s < 0
        @test_throws Exception Machine("M", ClassicalMachineParams(s = -1))
    end

    @testset "Machines" begin
        # Test a general constructor
        M = Machines()
        @test typeof(M) == Vector{Machine} && length(M) == 0

        # Test a constructor for identical machines
        M = Machines(100)
        @test typeof(M) == Vector{Machine} &&
              length(M) == 100 &&
              all(typeof(m.params) == ClassicalMachineParams for m in M) &&
              all(machine.params.s == 1 for machine in M)

         # Test a constructor for an array of integers
         A = [1, 5, 2, 3, 4, 1, 7, 8, 12, 18, 7, 3]
         M = Machines(A)
         @test typeof(M) == Vector{Machine} &&
               length(M) == 12 &&
               all(typeof(m.params) == ClassicalMachineParams for m in M) &&
               all(M[i].params.s == A[i] for i in 1:length(M))

         # Test a constructor for an array of rationals
         A = [1//2, 5//2, 2//3, 3//4, 4//1, 1//6, 7//9, 8//12, 12//6, 18//3, 7//4, 3//2]
         M = Machines(A)
         @test typeof(M) == Vector{Machine} &&
               length(M) == 12 &&
               all(typeof(m.params) == ClassicalMachineParams for m in M) &&
               all(M[i].params.s == A[i] for i in 1:length(M))

         # The following test whether an exception is thrown if s < 0
         @test_throws Exception Machines([1, 2, -1])
         @test_throws Exception Machines([1//2, 2//1, -1//2])
    end

    @testset "JobAssignment" begin
        J = Job("J")
        M = Machine("M")

        # Test a general constructor for integers
        A = JobAssignment(J, M, 1, 5)
        @test typeof(A) == JobAssignment &&
              A.J === J &&
              A.P.M === M &&
              A.P.S == 1 &&
              A.P.C == 5

        # Test a general constructor for rationals
        A = JobAssignment(J, M, 1//2, 5//3)
        @test typeof(A) == JobAssignment &&
              A.J === J &&
              A.P.M === M &&
              A.P.S == 1//2 &&
              A.P.C == 5//3

        # The following tests whether an exception is thrown if C < S
        @test_throws Exception JobAssignment(J, M, 2, 1)
        @test_throws Exception JobAssignment(J, M, 2//3, 1//4)
    end

    @testset "JobAssignments" begin
        # Test a general constructor
        A = JobAssignments()
        @test typeof(A) == Vector{JobAssignment} && length(A) == 0
    end

    @testset "Schedule" begin
        J = Jobs()
        M = Machines()
        A = JobAssignments()

        # Test a general constructor
        S = Schedule()
        @test typeof(S) == Schedule

        # Test a constructor for predefined arguments
        S = Schedule(J)
        @test typeof(S) == Schedule &&
              S.jobs === J
        S = Schedule(J, M)
        @test typeof(S) == Schedule &&
              S.jobs === J &&
              S.machines === M
        S = Schedule(J, M, A)
        @test typeof(S) == Schedule &&
              S.jobs === J &&
              S.machines === M &&
              S.assignments === A
    end
end

@testset "Objectives" begin
      # Create a set of jobs
      J = Jobs()
      push!(J, Job("J", ClassicalJobParams(p = 7, d = 6, w = 2)))
      push!(J, Job("J", ClassicalJobParams(p = 2, d = 4)))
      push!(J, Job("J", ClassicalJobParams(p = 4, d = 1000, w = -1)))
      push!(J, Job("J", ClassicalJobParams(p = 8, d = 1273//3)))
      push!(J, Job("J", ClassicalJobParams(p = 3, w = 3)))
      push!(J, Job("J", ClassicalJobParams(p = 4, w = 6)))
      push!(J, Job("J", ClassicalJobParams(p = 8, w = -4//3)))

      # Create a set of machines
      M = Machines(3)

      # A schedule
      S1 = Schedule(J, M, [
            JobAssignment(J[1], M[1], 0, 7)           # (C, U, L, T) = (7, 1, 1, 1)
            JobAssignment(J[2], M[2], 1, 3)           # (C, U, L, T) = (3, 0, -1, 0)
            JobAssignment(J[3], M[1], 7, 11)          # (C, U, L, T) = (11, 0, -989, 0)
            JobAssignment(J[4], M[3], 1//3, 25//3)    # (C, U, L, T) = (25//3, 0, -1248//3, 0)
      ])

      # A schedule with negative weights and a tardy job
      S2 = Schedule(J, M, [
            JobAssignment(J[3], M[1], 2000, 2004)     # (C, U, L, T) = (2004, 1, 1004, 1004)
            JobAssignment(J[7], M[2], 2//3, 26//3)    # (C, U, L, T) = (26//3, 0, -Inf, 0)
      ])

      # A schedule with infinite due dates
      S3 = Schedule(J, M, [
            JobAssignment(J[5], M[1], 1, 4)           # (C, U, L, T) = (4, 0, -Inf, 0)
            JobAssignment(J[6], M[2], 101//2, 109//2) # (C, U, L, T) = (109//2, 0, -Inf, 0)
            JobAssignment(J[7], M[3], 0, 8)           # (C, U, L, T) = (8, 0, -Inf, 0)
      ])

      @testset "cmax" begin
            @test cmax(S1) == 11
            @test cmax(S2) == 2004
            @test cmax(S3) == 109//2
      end

      @testset "csum" begin
            @test csum(S1) == 88//3
            @test csum(S2) == 6038//3
            @test csum(S3) == 133//2
      end

      @testset "wcsum" begin
            @test wcsum(S1) == 43//3
            @test wcsum(S2) == -18140//9
            @test wcsum(S3) == 985//3
      end

      @testset "lmax" begin
            @test lmax(S1) == 1
            @test lmax(S2) == 1004
            @test lmax(S3) == -Inf
            @test lmax(S3) == -1//0
      end

      @testset "nt" begin
            @test nt(S1) == 1
            @test nt(S2) == 1
            @test nt(S3) == 0
      end

      @testset "wnt" begin
            @test wnt(S1) == 2
            @test wnt(S2) == -1
            @test wnt(S3) == 0
      end

      @testset "tsum" begin
            @test tsum(S1) == 1
            @test tsum(S2) == 1004
            @test tsum(S3) == 0
      end

      @testset "wtsum" begin
            @test wtsum(S1) == 2
            @test wtsum(S2) == -1004
            @test wtsum(S3) == 0
      end
end

include("algorithms/Q_prmp_Cmax.jl")