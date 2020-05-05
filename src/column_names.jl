
const MALE_COLUMNS = [:m1, :m2, :m3]
const FEMALE_COLUMNS = [:f1, :f2, :f3]
const ALL_FACULTY = vcat(FEMALE_COLUMNS, MALE_COLUMNS)

const INTEGER_COLUMNS = [:f1, :f2, :f3,
                :m1, :m2, :m3,
                :lev1, :lev2, :lev3,
                :f, :m, :deptn,

                :fattr1, :fattr2, :fattr3,
                :mattr1, :mattr2, :mattr3,
                :attr1, :attr2, :attr3,
                :attr, :fattr, :mattr,

                :fhire1, :fhire2, :fhire3,
                :mhire1, :mhire2, :mhire3,
                :fhire, :mhire, :hire,
                :hire1, :hire2, :hire3,

                :fprom1, :fprom2, :mprom1,
                :mprom2, :prom, :prom1,
                :prom2, :prom3, :fprom,
                :mprom,

                :f1_1d, :f2_1d, :f3_1d,
                :m1_1d, :m2_1d, :m3_1d, :deptn_1d,

                :ss_deptn_ub, :ss_deptn_lb, :ss_duration,
                :runn, :yr, :year, :run,
]

const FLOAT_COLUMNS = [:fpct1, :fpct2, :fpct3,
                :mpct1, :mpct2, :mpct3,
                :fpct,

                :r_fattr1, :r_fattr2, :r_fattr3,
                :r_mattr1, :r_mattr2, :r_mattr3,
                :r_attr,

                :r_fhire1, :r_fhire2, :r_fhire3,
                :r_mhire1, :r_mhire2, :r_mhire3,
                :r_hire, :r_hire_adj,

                :r_fprom1, :r_fprom2, :r_fprom3,
                :r_mprom1, :r_mprom2, :r_mprom3,

                :g_yr_rate
]

const DECORATOR_COLUMNS = [
                :scen, :date_time, :notes,
                :model, :language
]

const UNSUMMARIZED_COLUMNS = [
                :r_fattr1, :r_fattr2, :r_fattr3,
                :r_mattr1, :r_mattr2, :r_mattr3,

                :r_fhire1, :r_fhire2, :r_fhire3,
                :r_mhire1, :r_mhire2, :r_mhire3,

                :r_fprom1, :r_fprom2, :r_fprom3,
                :r_mprom1, :r_mprom2, :r_mprom3,
                :ss_deptn_ub, :ss_deptn_lb, :ss_duration,
                :runn, :ss_deptn_range, :r_hire,
                :r_hire_adj, :r_attr, :g_yr_rate
]

const TEXT_COLUMNS = [:scen, :model, :notes, :language, :date_time]

const DATE_TIME = [:date_time]
