
include("column_names.jl")


function demographic_inertia_simulation(initial_values,
                                        runs,
                                        duration)

    # build the data array
    initial_values["duration"] = duration # TODO bad programming style. Need to fix this.
    res = build_simulation_results_array(runs, duration)
    populate_initial_values!(res, initial_values)
    run_model_with_drift!(res, initial_values, runs)
    @bp
    res
end

function build_simulation_results_array(runs,
                                        duration)
    num_rows = runs * duration
    int_df = DataFrame(repeat([Union{Int64, Missing}], size(INTEGER_COLUMNS)[1]),
                INTEGER_COLUMNS,
                runs * duration)

    float_df = DataFrame(repeat([Union{Float64, Missing}], size(FLOAT_COLUMNS)[1]),
                FLOAT_COLUMNS,
                runs * duration)
    #df[!, :scen] .= Union{String, Missing}
    text_df = DataFrame(repeat([Union{String, Missing}], size(TEXT_COLUMNS)[1]),
                TEXT_COLUMNS,
                runs * duration)
    text_df[!, :date_time] .= Dates.format(Dates.now(), "mm/dd/yyyy HH:MM")
    hcat(int_df, float_df, text_df)

end

function populate_initial_values!(ra, iv)
    ra[1, :f1] = iv["number_of_females_1"]
    ra[1, :f2] = iv["number_of_females_2"]
    ra[1, :f3] = iv["number_of_females_3"]
    ra[1, :m1] = iv["number_of_males_1"]
    ra[1, :m2] = iv["number_of_males_2"]
    ra[1, :m3] = iv["number_of_males_3"]
    ra[1, :lev1] = iv["number_of_females_1"] + iv["number_of_males_1"]
    ra[1, :lev2] = iv["number_of_females_2"] + iv["number_of_males_2"]
    ra[1, :lev3] = iv["number_of_females_3"] + iv["number_of_males_3"]
    ra[1, :f] = iv["number_of_females_1"] + iv["number_of_females_2"] + iv["number_of_females_3"]
    ra[1, :m] = iv["number_of_males_1"] + iv["number_of_males_2"] + iv["number_of_males_3"]
    ra[1, :fpct1] = round(ra[1, :f1]/ra[1, :lev1], digits=3)
    ra[1, :fpct2] = round(ra[1, :f2]/ra[1, :lev2], digits=3)
    ra[1, :fpct3] = round(ra[1, :f3]/ra[1, :lev3], digits=3)
    ra[1, :mpct1] = round(1 - ra[1, :fpct1], digits=3)
    ra[1, :mpct2] = round(1 - ra[1, :fpct2], digits=3)
    ra[1, :mpct3] = round(1 - ra[1, :fpct3], digits=3)
    ra[1, :fpct] = round(sum(ra[1,:f])/sum(ra[1, ALL_FACULTY]), digits=3)
    ra[1, :deptn] = sum(ra[1, ALL_FACULTY])
    ra[1, :attr] = 0
    ra[1, :run] = 0
    ra[1, :yr] = 0
    ra[1, :year] = 0
    ra[1, :hire] = 0
    ra[1, :r_attr] = 0.
    ra[1, :r_hire] = 0.
    ra[1, :r_hire_adj] = 0.
    ra[1, :f1_1d] = 0
    ra[1, :f2_1d] = 0
    ra[1, :f3_1d] = 0
    ra[1, :m1_1d] = 0
    ra[1, :m2_1d] = 0
    ra[1, :m3_1d] = 0
    ra[1, :deptn_1d] = 0
    ra[:, :r_fhire1] .= iv["hiring_rate_women_1"]
    ra[:, :r_fhire2] .= iv["hiring_rate_women_2"]
    ra[:, :r_fhire3] .= iv["hiring_rate_women_3"]
    ra[:, :r_mhire1] .= iv["hiring_rate_men_1"]
    ra[:, :r_mhire2] .= iv["hiring_rate_men_2"]
    ra[:, :r_mhire3] .= iv["hiring_rate_men_3"]
    ra[:, :r_fattr1] .= iv["attrition_rate_women_1"]
    ra[:, :r_fattr2] .= iv["attrition_rate_women_2"]
    ra[:, :r_fattr3] .= iv["attrition_rate_women_3"]
    ra[:, :r_mattr1] .= iv["attrition_rate_men_1"]
    ra[:, :r_mattr2] .= iv["attrition_rate_men_2"]
    ra[:, :r_mattr3] .= iv["attrition_rate_men_3"]
    ra[:, :r_fprom1] .= iv["female_promotion_probability_1"]
    ra[:, :r_fprom2] .= iv["female_promotion_probability_2"]
    ra[:, :r_mprom1] .= iv["male_promotion_probability_1"]
    ra[:, :r_mprom2] .= iv["male_promotion_probability_2"]
    ra[:, :prom3] .= 0
    ra[:, :r_fprom3] .= 0.
    ra[:, :r_mprom3] .= 0.
    ra[:, :ss_deptn_ub] .= iv["upperbound"]
    ra[:, :ss_deptn_lb] .= iv["lowerbound"]
    ra[:, :ss_deptn_range] .= ra[:, :ss_deptn_ub] - ra[:, :ss_deptn_lb]
    ra[:, :ss_duration] .= iv["duration"]
    ra[:, :model] .= iv["model_name"]
    ra[:, :language] .= "julia"
    ra[:, :scen] .= "scenario name"
    ra[:, :notes] .= "notes"
end

function run_model_with_drift!(df, initial_values, runs)

    department_size_forecasts = calculate_yearly_dept_size_targets(df[1, :ss_duration], initial_values["growth_rate"])

    dept_attr_rate = mean(df[1, [:r_fattr1,
                                :r_fattr2,
                                :r_fattr3,
                                :r_mattr1,
                                :r_mattr2,
                                :r_mattr3 ]])
    base_hiring_rate = dept_attr_rate

    df[1, :g_yr_rate] = department_size_forecasts[1] # TODO move this within the loop to set initial growth value
    df[:, :runn] .= runs

    @showprogress for j in 1:runs

        for i in 2:df[1,:ss_duration]
            k = i + (j-1)*df[1, :ss_duration]
            if i == 2
                df[k-1, :f1] = df[1, :f1]
                df[k-1, :f2] = df[1, :f2]
                df[k-1, :f3] = df[1, :f3]
                df[k-1, :m1] = df[1, :m1]
                df[k-1, :m2] = df[1, :m2]
                df[k-1, :m3] = df[1, :m3]
                df[k-1, :lev1] = df[1, :lev1]
                df[k-1, :lev2] = df[1, :lev2]
                df[k-1, :lev3] = df[1, :lev3]
                df[k-1, :f] = df[1, :f]
                df[k-1, :m] = df[1, :m]
                df[k-1, :fpct1] = df[1, :fpct1]
                df[k-1, :fpct2] = df[1, :fpct2]
                df[k-1, :fpct3] = df[1, :fpct3]
                df[k-1, :mpct1] = df[1, :mpct1]
                df[k-1, :mpct2] = df[1, :mpct2]
                df[k-1, :mpct3] = df[1, :mpct3]
                df[k-1, :fpct] = df[1, :fpct]
                df[k-1, :deptn] = df[1, :deptn]
                df[k-1, :attr] = df[1, :m3]
                df[k-1, :run] = j-1
                df[k-1, :yr] = i-2 # sets yr to 0.
                df[k-1, :year] = i-2
                df[k-1, :r_attr] = df[1, :attr]
                df[k-1, :r_hire] = df[1, :hire]
                df[k-1, :r_hire_adj] = df[1, :r_hire_adj]
                df[k-1, :f1_1d] = df[1, :f1_1d]
                df[k-1, :f2_1d] = df[1, :f2_1d]
                df[k-1, :f3_1d] = df[1, :f3_1d]
                df[k-1, :m1_1d] = df[1, :m1_1d]
                df[k-1, :m2_1d] = df[1, :m2_1d]
                df[k-1, :m3_1d] = df[1, :m3_1d]
                df[k-1, :deptn_1d] = df[1, :deptn_1d]
            end

            df[k, :yr] = i - 1
            df[k, :year] = i - 1
            df[k, :run] = j - 1

            # process attritions
            df[k, :fattr1] = rand(Binomial(df[k-1, :f1], df[k-1, :r_fattr1]), 1)[1]
            df[k, :fattr2] = rand(Binomial(df[k-1, :f2], df[k-1, :r_fattr2]), 1)[1]
            df[k, :fattr3] = rand(Binomial(df[k-1, :f3], df[k-1, :r_fattr3]), 1)[1]
            df[k, :mattr1] = rand(Binomial(df[k-1, :m1], df[k-1, :r_mattr1]), 1)[1]
            df[k, :mattr2] = rand(Binomial(df[k-1, :m2], df[k-1, :r_mattr2]), 1)[1]
            df[k, :mattr3] = rand(Binomial(df[k-1, :m3], df[k-1, :r_mattr3]), 1)[1]

            # update model numbers after attrition
            df[k, :f1] = df[k-1, :f1 ] - df[k, :fattr1]
            df[k, :f2] = df[k-1, :f2 ] - df[k, :fattr2]
            df[k, :f3] = df[k-1, :f3 ] - df[k, :fattr3]
            df[k, :m1] = df[k-1, :m1 ] - df[k, :mattr1]
            df[k, :m2] = df[k-1, :m2 ] - df[k, :mattr2]
            df[k, :m3] = df[k-1, :m3 ] - df[k, :mattr3]

            # promotion process

            df[k, :fprom2] = rand(Binomial(df[k, :f2], df[k-1, :r_fprom2]), 1)[1]
            df[k, :fprom1] = rand(Binomial(df[k, :f1], df[k-1, :r_fprom1]), 1)[1]
            df[k, :mprom2] = rand(Binomial(df[k, :m2], df[k-1, :r_mprom2]), 1)[1]
            df[k, :mprom1] = rand(Binomial(df[k, :m1], df[k-1, :r_mprom1]), 1)[1]

            df[k, :prom1] = sum(df[k, [:fprom1, :mprom1]])
            df[k, :prom2] = sum(df[k, [:fprom2, :mprom2]])
            df[k, :prom3] = 0
            df[k, :fprom] = sum(df[k, [:fprom1, :fprom2]])
            df[k, :mprom] = sum(df[k, [:mprom1, :mprom2]])
            df[k, :prom] = sum(df[k, [:fprom, :mprom]])

            # update model numbers after promotion
            # add promotions to senior level
            df[k, :f2] += df[k, :fprom1]
            df[k, :f3] += df[k, :fprom2]
            df[k, :m2] += df[k, :mprom1]
            df[k, :m3] += df[k, :mprom2]

            # remove promoted folks from previous levels
            df[k, :f1] -= df[k, :fprom1]
            df[k, :f2] -= df[k, :fprom2]
            df[k, :m1] -= df[k, :mprom1]
            df[k, :m2] -= df[k, :mprom2]

            # hiring new faculty
            base_hr_with_growth = base_hiring_rate + department_size_forecasts[i]
            lower_bound_adjustment = base_hr_with_growth/(1 + exp(df[k-1, :deptn] - df[k, :ss_deptn_lb]))
            upper_bound_adjustment = base_hr_with_growth/(1 + exp(df[k, :ss_deptn_ub] - df[k-1, :deptn]))
            dept_adjusted_hiring_rate = max(base_hr_with_growth + lower_bound_adjustment - upper_bound_adjustment, 0)
            df[k, :r_attr] = dept_attr_rate
            df[k, :r_hire] = base_hiring_rate
            df[k, :r_hire_adj] = dept_adjusted_hiring_rate

            total_vacancies = rand(Binomial(df[k-1, :deptn], dept_adjusted_hiring_rate), 1)[1]
            hiring_probabilities = [df[k, :r_fhire1],
                                    df[k, :r_fhire2],
                                    df[k, :r_fhire3],
                                    df[k, :r_mhire1],
                                    df[k, :r_mhire2],
                                    df[k, :r_mhire3]]

            hires = rand(Multinomial(total_vacancies,(hiring_probabilities/sum(hiring_probabilities))), 1)

            df[k, :f1] += hires[1]
            df[k, :f2] += hires[2]
            df[k, :f3] += hires[3]
            df[k, :m1] += hires[4]
            df[k, :m2] += hires[5]
            df[k, :m3] += hires[6]

            df[k, :fhire1] = hires[1]
            df[k, :fhire2] = hires[2]
            df[k, :fhire3] = hires[3]
            df[k, :mhire1] = hires[4]
            df[k, :mhire2] = hires[5]
            df[k, :mhire3] = hires[6]

            df[k, :hire1] = sum(df[k, [:fhire1, :mhire1]])
            df[k, :hire2] = sum(df[k, [:fhire2, :mhire2]])
            df[k, :hire3] = sum(df[k, [:fhire3, :mhire3]])
            df[k, :mhire] = sum(df[k, [:mhire1, :mhire2, :mhire3]])
            df[k, :fhire] = sum(df[k, [:fhire1, :fhire2, :fhire3]])
            df[k, :hire] = sum(hires)

            # save system state
            df[k, :attr1] = sum(df[k, [:fattr1, :mattr1]])
            df[k, :attr2] = sum(df[k, [:fattr2, :mattr2]])
            df[k, :attr3] = sum(df[k, [:fattr3, :mattr3]])
            df[k, :fattr] = sum(df[k, [:fattr1, :fattr2, :fattr3]])
            df[k, :mattr] = sum(df[k, [:mattr1, :mattr2, :mattr3]])
            df[k, :attr] = sum(df[k, [:fattr, :mattr]])

            df[k, :fpct] = round(sum(df[k, FEMALE_COLUMNS])/sum(df[k, ALL_FACULTY]), digits=3)
            df[k, :fpct1] = round(df[k, :f1]/sum(df[k, [:f1, :m1]]), digits=3)
            df[k, :fpct2] = round(df[k, :f2]/sum(df[k, [:f2, :m2]]), digits=3)
            df[k, :fpct3] = round(df[k, :f3]/sum(df[k, [:f3, :m3]]), digits=3)
            df[k, :mpct1] = round(df[k, :m1]/sum(df[k, [:f1, :m1]]), digits=3)
            df[k, :mpct2] = round(df[k, :m2]/sum(df[k, [:f2, :m2]]), digits=3)
            df[k, :mpct3] = round(df[k, :m3]/sum(df[k, [:f3, :m3]]), digits=3)

            df[k, :deptn] = sum(df[k, ALL_FACULTY])
            df[k, :lev1] = sum(df[k, [:f1, :m1]])
            df[k, :lev2] = sum(df[k, [:f2, :m2]])
            df[k, :lev3] = sum(df[k, [:f3, :m3]])
            df[k, :f] = sum(df[k, FEMALE_COLUMNS])
            df[k, :m] = sum(df[k, MALE_COLUMNS])

            df[k, :g_yr_rate] = department_size_forecasts[i]
            df[k, :f1_1d] = df[k, :f1] - df[k-1, :f1]
            df[k, :f2_1d] = df[k, :f2] - df[k-1, :f2]
            df[k, :f3_1d] = df[k, :f3] - df[k-1, :f3]
            df[k, :m1_1d] = df[k, :m1] - df[k-1, :m1]
            df[k, :m2_1d] = df[k, :m2] - df[k-1, :m2]
            df[k, :m3_1d] = df[k, :m3] - df[k-1, :m3]
            df[k, :deptn_1d] = df[k, :deptn] - df[k-1, :deptn]
        end
    end
    CSV.write("model_simulation_detail_$(Dates.format(Dates.now(), "mm-dd-yyyy HH:MM")).csv", df)
    df
end

function _calculate_forecast_interval(duration, forecasts_list)
    convert(UInt16, ceil(duration/length(forecasts_list)))
end

function calculate_yearly_dept_size_targets(duration, forecasts_list)
    repeat_interval = _calculate_forecast_interval(duration, forecasts_list)
    repeat(forecasts_list, inner=repeat_interval)
end

function calculate_simulation_summary(sim; criterion = 0.25)
    # subset the dataframe with the columns that are to be summarized

    reduced_df = select(sim, Not(unique(vcat(UNSUMMARIZED_COLUMNS, DECORATOR_COLUMNS, :run))))
    unsummarized_df = select(sim, unique(vcat(UNSUMMARIZED_COLUMNS, :yr)))
    text_df = select(sim, vcat(TEXT_COLUMNS, :yr))
    # aggregate over the dataframe

    summary = aggregate(reduced_df, :yr,
                        [mean, std, _025, _975])
    summary = replace_nans.(summary)
    summary = round.(summary, digits=3)
    p_fpct = by(sim, :yr, :fpct =>
            x -> p_fpct = 1 - sum(x .<= criterion)/length(x))
    p_fpct = rename(select(p_fpct, :fpct_function), [:p_fpct])
    summary = hcat(summary, p_fpct)

    unsummarized = aggregate(unsummarized_df, :yr, mean)
    unsummarized = select(unsummarized, Not(:yr))
    unsummarized = update_unsummarized_column_names!(unsummarized)
    unsummarized = round.(unsummarized, digits=3)

    text_summary = aggregate(text_df, :yr, return_first_element)
    text_summary = select(text_summary, Not(:yr))
    text_summary = update_text_column_names!(text_summary)

    summary = hcat(summary, unsummarized)
    summary = update_column_names!(summary)
    summary = hcat(summary, text_summary)
    # create non_summarized colums, but of the same length as the summarized dataframe

    # concatenate the dataframes
    summary = concatenate_actual_data_to_simulation!(summary)

    CSV.write("model_summary_$(Dates.format(Dates.now(), "mm-dd-yyyy HH:MM")).csv", summary)

    simulation = replace_nans.(sim)
    return simulation, summary
end

# function calculate_probability_of_target(criterion::Float64, df::DataFrame)
#     df2 = @byrow! df begin
#         @newcol p_fpct::Array{Float64}
#         :p_fpct = 1 - sum()
# end
# end

function calculate_empirical_probability_of_value(criterion, data_vector)
    emp_prob = 1 - sum(data_vector .<= criterion)/length(data_vector)
    emp_prob
end

function _025(x)
    if any(ismissing, x)
        return NaN
    else
        return quantile(collect(skipmissing(x)), 0.025)
    end
end

function _975(x)
    if any(ismissing, x)
        return NaN
    else
        return quantile(collect(skipmissing(x)), 0.975)
    end
end

function return_first_element(x::AbstractArray)
    if ismissing(x[1])
        return missing
    else
        return x[1]
    end
end

function update_column_names!(df)
    vec_names = string.(names(df))
    vec_names = replace.(vec_names, "__" => "_")
    vec_names = replace.(vec_names, "mean" => "avg")
    sym_names = Symbol.(vec_names)
    rename!(df, sym_names)
end

function update_unsummarized_column_names!(df)
    vec_names = string.(names(df))
    vec_names = replace.(vec_names, "_mean" => "")
    sym_names = Symbol.(vec_names)
    rename!(df, sym_names)
end

function update_text_column_names!(df)
    vec_names = string.(names(df))
    vec_names = replace.(vec_names, "_return_first_element" => "")
    sym_names = Symbol.(vec_names)
    rename!(df, sym_names)
end

function concatenate_actual_data_to_simulation!(df_simulation::DataFrame)
    df_actual = CSV.read(joinpath(@__DIR__, "mgmt_data.csv"))

    if size(df_simulation)[1] > size(df_actual)[1]
        difference = size(df_simulation)[1] - size(df_actual)[1]
        missing_df = missings(difference, size(df_actual)[2]) |> DataFrame
        rename!(missing_df, names(df_actual))
        padded_df = vcat(df_actual, missing_df)
        df_simulation = hcat(padded_df, df_simulation)
    elseif size(df_simulation)[1] == size(df_actual)[1]
        df_simulation = hcat(df_actual, df_simulation)
    else
        difference = size(df_actual)[1] - size(df_simulation)[1]
        df_simulation = hcat(df_actual[1:size(df_simulation)[1], :], df_simulation)
    end
    return df_simulation
end

function find_intersection_of_names(a::AbstractArray, b::AbstractArray)
    findall(in(b),a)
end

function replace_nans(a::Union{Real, Missing})
    if ismissing(a)
        return a
    elseif isnan(a)
        return missing
    else
        return a
    end
end
