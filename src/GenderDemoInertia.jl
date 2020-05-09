module GenderDemoInertia
using DataFrames
using Dates
using Distributions
using Statistics
using CSV
using Debugger
using Missings
using DataFramesMeta
import Pandas
import DataValues

include("model_demographic_inertia_gender.jl")
include("../test/conftest.jl")

export run_gender_inertia_simulation, TESTDATA

function run_gender_inertia_simulation(initial_values, runs, duration)
    res = demographic_inertia_simulation(initial_values, runs, duration)
    res;
    end


function get_summaries(initial_values, runs, duration)
    simulation_data = demographic_inertia_simulation(initial_values, runs, duration)
    summary = calculate_simulation_summary(simulation_data)
    summary ;
end

#@run run_gender_inertia_simulation(TESTDATA, 2, 20)
#@run run_gender_inertia_simulation(TESTDATA, 100, 6)
#@run GenderDemoInertia.get_summaries(GenderDemoInertia.TESTDATA, 100, 6)

struct MyProblemColumn <: Exception
    var::Symbol
end


function check_column_errors(df::DataFrames.DataFrame)

    for c in names(df)
        try
            println("Check column $c, type $(eltype(df[:,c])) .")
            Pandas.DataFrame(select(df, c))
        catch e
            if isa(e, MethodError)
                println("the problem column is $c")
                println("The datatype of the column is $(eltype(df[c]))")
                throw()
            else
                println("Error encountered on column $c")
                println(e)
            end
        end
    end
    println("Check complete.")
end

end  # Module end
