

const column_names = [:f1, :f2, :f3,
                :m1, :m2, :m3,
                :lev1, :lev2, :lev3,
                :f, :m, :fpct1,
                :deptn,

                :fpct1, :fpct2, :fpct3,
                :mpct1, :mpct2, :mpct3,
                :fpct,

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

                :r_fattr1, :r_fattr2, :r_fattr3,
                :r_mattr1, :r_mattr2, :r_mattr3,
                :r_attr,

                :r_fhire1, :r_fhire2, :r_fhire3,
                :r_mhire1, :r_mhire2, :r_mhire3,
                :r_hire, :r_hire_adj,

                :r_fprom1, :r_fprom2, :r_fprom3,
                :r_mprom1, :r_mprom2, :r_mprom3,

                :ss_deptn_ub, :ss_deptn_lb, :ss_duration,
                :runn, :yr,
]

const decorator_columns = [
                :scen, :date_time, :notes,
                :model
]

const unsummarized_columns = [:yr, :date_time,
                :r_fattr1, :r_fattr2, :r_fattr3,
                :r_mattr1, :r_mattr2, :r_mattr3,

                :r_fhire1, :r_fhire2, :r_fhire3,
                :r_mhire1, :r_mhire2, :r_mhire3,

                :r_fprom1, :r_fprom2, :r_fprom3,
                :r_mprom1, :r_mprom2, :r_mprom3,

                :runn, :scen
]
