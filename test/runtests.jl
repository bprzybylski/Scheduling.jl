using Scheduling, Test

@testset "Types" begin
    @testset "Job" begin
        # Test a job constructor
        J = Job("I love scheduling")
        @test typeof(J) == Job &&
              J.p == 1 &&
              J.name == "I love scheduling"

        J = Job("I love scheduling", p = 3, w = 10, r = 2, d = 7, D = 8)
        @test typeof(J) == Job &&
              J.p == 3 &&
              J.w == 10 &&
              J.r == 2 &&
              J.d == 7 &&
              J.D == 8 &&
              J.name == "I love scheduling"

        J = Job("I love scheduling", p = 3//2, w = 10//3, r = 2//3, d = 7//2, D = 8//2)
        @test typeof(J) == Job &&
             J.p == 3//2 &&
             J.w == 10//3 &&
             J.r == 2//3 &&
             J.d == 7//2 &&
             J.D == 8//2 &&
             J.name == "I love scheduling"

        # The following tests whether an exception is thrown if r + p > D
        @test_throws Exception Job("J", r = 5, p = 100, D = 104)
    end

    @testset "Jobs" begin
        # Test a general constructor
        J = Jobs()
        @test typeof(J) == Vector{Job} && length(J) == 0

        # Test a constructor for identical jobs
        J = Jobs(100)
        @test typeof(J) == Vector{Job} &&
              length(J) == 100 &&
              all(job.p == 1 for job in J)

         # Test a constructor for an array of integers
         A = [1, 5, 2, 3, 4, 1, 7, 8, 12, 18, 7, 3]
         J = Jobs(A)
         @test typeof(J) == Vector{Job} &&
               length(J) == 12 &&
               all(J[i].p == A[i] for i in 1:length(J))

         # Test a constructor for an array of rationals
         A = [1//2, 5//2, 2//3, 3//4, 4//1, 1//6, 7//9, 8//12, 12//6, 18//3, 7//4, 3//2]
         J = Jobs(A)
         @test typeof(J) == Vector{Job} &&
               length(J) == 12 &&
               all(J[i].p == A[i] for i in 1:length(J))

         # The following test whether an exception is thrown if p < 0
         @test_throws Exception Jobs([1, 2, -1])
         @test_throws Exception Jobs([1//2, 2//1, -1//2])
    end

    @testset "Machine" begin
        # Test a machine constructor
        M = Machine("I love scheduling")
        @test typeof(M) == Machine &&
              M.s == 1 &&
              M.name == "I love scheduling"

        M = Machine("I love scheduling", s = 3)
        @test typeof(M) == Machine &&
              M.s == 3 &&
              M.name == "I love scheduling"

        M = Machine("I love scheduling", s = 3//2)
        @test typeof(M) == Machine &&
              M.s == 3//2 &&
              M.name == "I love scheduling"

        # The following tests whether an exception is thrown if s < 0
        @test_throws Exception Machine("M", s = -1)
    end

    @testset "Machines" begin
        # Test a general constructor
        M = Machines()
        @test typeof(M) == Vector{Machine} && length(M) == 0

        # Test a constructor for identical machines
        M = Machines(100)
        @test typeof(M) == Vector{Machine} &&
              length(M) == 100 &&
              all(machine.s == 1 for machine in M)

         # Test a constructor for an array of integers
         A = [1, 5, 2, 3, 4, 1, 7, 8, 12, 18, 7, 3]
         M = Machines(A)
         @test typeof(M) == Vector{Machine} &&
               length(M) == 12 &&
               all(M[i].s == A[i] for i in 1:length(M))

         # Test a constructor for an array of rationals
         A = [1//2, 5//2, 2//3, 3//4, 4//1, 1//6, 7//9, 8//12, 12//6, 18//3, 7//4, 3//2]
         M = Machines(A)
         @test typeof(M) == Vector{Machine} &&
               length(M) == 12 &&
               all(M[i].s == A[i] for i in 1:length(M))

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
              A.M === M &&
              A.S == 1 &&
              A.C == 5

        # Test a general constructor for rationals
        A = JobAssignment(J, M, 1//2, 5//3)
        @test typeof(A) == JobAssignment &&
              A.J === J &&
              A.M === M &&
              A.S == 1//2 &&
              A.C == 5//3

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
