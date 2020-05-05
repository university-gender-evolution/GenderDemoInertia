using GenderDemoInertia
using Test
include("conftest.jl")


@testset "Test column name imports from column_names.jl" begin
    @test :deptn ∈ GenderDemoInertia.INTEGER_COLUMNS
    @test :scen ∈ GenderDemoInertia.decorator_columns
    @test :runn ∈ GenderDemoInertia.UNSUMMARIZED_COLUMNS
end

@testset "Test import of model_demographic_inertia_gender.jl" begin
    # @test GenderDemoInertia.probability(3,4) = 7
    @test TESTDATA["hiring_rate_women_1"] == 0.2059
    @test TESTDATA["attrition_rate_women_2"] == 0.00
    @test size(GenderDemoInertia.build_simulation_results_array(2, 10)) == (20,93)
    @test GenderDemoInertia.demographic_inertia_simulation(TESTDATA, 100, 100)[1, :r_fattr1] == 0.0615
    #@test GenderDemoInertia.run_gender_inertia_simulation(TESTDATA, 2, 2)
end
