using Test, ChemicalOfTheDay, Dates, Twitter, Random
@info "usings"
status = build_status(962);
@show status


@test ChemicalOfTheDay.is_chem_live(ChemicalOfTheDay.get_json_and_view_from_cid(962)[2])

chem = ChemicalOfTheDay.get_json_and_view_from_cid(83630989);
j, jv = chem;
@test !ChemicalOfTheDay.is_chem_live(jv)
