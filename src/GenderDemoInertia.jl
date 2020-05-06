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
include("model_demographic_inertia_gender.jl")
include("../test/conftest.jl")

export run_gender_inertia_simulation, TESTDATA

function run_gender_inertia_simulation(initial_values, runs, duration)
    res = demographic_inertia_simulation(initial_values, runs, duration)
    res;
    end

#@run run_gender_inertia_simulation(TESTDATA, 2, 20)
#@run run_gender_inertia_simulation(TESTDATA, 100, 6)

function get_summaries(initial_values, runs, duration)
    simulation_data = demographic_inertia_simulation(initial_values, runs, duration)
    summary = calculate_simulation_summary(simulation_data)
    summary ;
end

#@run GenderDemoInertia.get_summaries(GenderDemoInertia.TESTDATA, 100, 6)

end  # Module end
