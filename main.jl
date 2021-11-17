using Colors
using FileIO
using GLMakie
using GeoJSON
using GeoMakie.GeoInterface
using XLSX

inzidenz_colors = [
    RGB(244/255, 225/255, 96/255),
    RGB(224/255, 164/255, 74/255),
    RGB(220/255, 117/255, 56/255),
    RGB(195/255, 75/255, 64/255),
    RGB(117/255, 47/255, 46/255)
]

read_kreise() = GeoJSON.read(read("landkreise.geojson"))

function color_for_inzidenz(x)
    if x <= 25
        inzidenz_colors[1]
    elseif x <= 50
        inzidenz_colors[2]
    elseif x <= 100
        inzidenz_colors[3]
    elseif x <= 250
        inzidenz_colors[4]
    elseif x <= 500
        inzidenz_colors[5]
    else
        RGB(0, 0, 0)
    end
end

function read_inzidenzen(rki_excel_file)
    xf = XLSX.readxlsx(rki_excel_file)
    rows = xf["LK_7-Tage-Inzidenz (fixiert)"][:][6:end, [3, end]]

    rows_with_content = filter(collect(eachrow(rows))) do row
        !ismissing(row[1])
    end
    Dict(map(rows_with_content) do row
         @sprintf("%05i", row[1]) => row[2]
    end)
end

function colors_from_rki(kreise, rki_excel_file)
    inz_dict = read_inzidenzen(rki_excel_file)
    map(kreise.features) do kreis
        ags = kreis.properties["AGS"]

        try
            color_for_inzidenz(inz_dict[ags])
        catch
            RGB(1, 1, 1) # white for not known data
        end
    end
end

function inzidenz_legend(scene::Scene, date)
    u25 = PolyElement(color = inzidenz_colors[1], strokecolor=:black)
    u50 = PolyElement(color = inzidenz_colors[2], strokecolor=:black)
    u100 = PolyElement(color = inzidenz_colors[3], strokecolor=:black)
    u250 = PolyElement(color = inzidenz_colors[4], strokecolor=:black)
    u500 = PolyElement(color = inzidenz_colors[5], strokecolor=:black)
    above = PolyElement(color = RGB(0, 0, 0), strokecolor=:black)

    leg = Legend(scene,
                 [u25, u50, u100, u250, u500, above],
                 ["<=25", "25<x<=50", "50<x<=100", "100<x<=250", "250<x<=500", "x>500"],
                 "7T-Inzidenz, $date",
                 patchsize=(35,35),
                 orientation=:vertical,
                 tellwidth=false,
                 tellheight=false,
                 halign=:center,
                 margin=(350, 0, 350, 0),
                )
end

function create_plot(kreise, colors, date)
    fig = Figure(resolution=(1500, 1920), title="11. November 2021")
    ax = fig[1,1] = Axis(fig)

    poly!(ax, kreise, color=colors, strokewidth=1, strokecolor=:white, )
    inzidenz_legend(fig.scene, date)

    display(fig)
    return fig
end

function rki_plot(rki_excel_file, date)
    kreise = read_kreise()
    colors = colors_from_rki(kreise, rki_excel_file)

    create_plot(kreise, colors, date)
end

