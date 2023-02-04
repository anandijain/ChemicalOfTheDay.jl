module ChemicalOfTheDay

using Twitter, Downloads, Random, JSON3, PubChemReactions, Dates


DATADIR = joinpath(@__DIR__, "../data/")
data(s) = joinpath(DATADIR, s)

function get_description(jview)
    secs = get_sections(jview)
    names_ids = get_names_ids_secs(secs)
    try
        rec_desc = find_toc(names_ids.Section)
        rec_desc.Information[1].Value.StringWithMarkup[1].String
    catch e
        @warn "no description found"
        return ""
    end

end
function date_value(id_secs;kw)
    create_sec = find_toc(id_secs; kw)
    only(create_sec.Information[1].Value.DateISO8601)
end

function get_create_modify_dates(jv;kw)
    secs = get_sections(jv)
    names_ids = get_names_ids_secs(secs)
    try
        date_value(names_ids.Section; kw)
    catch e
        @warn "no dates found"
        missing
    end
end

get_sections(jview) = jview.Record.Section
get_names_ids_secs(secs) = secs[only(findall(x -> x.TOCHeading == "Names and Identifiers", secs))]
find_toc(secs; kw="Record Description") = secs[only(findall(x -> x.TOCHeading == kw, secs))]

function build_status(id)
    chem = PubChemReactions.get_json_and_view_from_cid(id)

    chema, jv = chem
    cid = chema.PC_Compounds[1].id.id.cid
    description = ChemicalOfTheDay.get_description(chem[2])
    name = jv.Record.RecordTitle
    formula = PubChemReactions.get_molecular_formula_from_jview(jv.Record)


    create_date = ChemicalOfTheDay.get_create_modify_dates(jv; kw="Create Date")
    modify_date = ChemicalOfTheDay.get_create_modify_dates(jv; kw="Modify Date")


    """The chemical of $(today()) is $(name) ($formula)!
    ID: $cid

    $description

    https://pubchem.ncbi.nlm.nih.gov/compound/$(cid)

    created: $(create_date)
    last modified: $(modify_date)
    #chemistry #pubchem #chemicaloftheday"""
end


export build_status
end # module ChemicalOfTheDay
