using GenderDemoInertia
using Test


@testset "Test column name imports from column_names.jl" begin
    @test :deptn ∈ GenderDemoInertia.column_names
    @test :scen ∈ GenderDemoInertia.decorator_columns
    @test :runn ∈ GenderDemoInertia.unsummarized_columns
end
@testset "Test import of model_demographic_inertia_gender.jl" begin
    @test probability(2,3) = 5
end
