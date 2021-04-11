# Inzidenzkarte von Deutschland

This is plotting script quickly hacked together to visualize official COVID-19
infection data for Germany by the Robert-Koch-Institute.

## Usage

To use, download one of the daily updated `.xlsx` files by the
[Robert-Koch-Institute](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html).
You can then open the julia console in the project with `julia --project=@.` and
resolve all dependencies with `]resolve`.

Finally, you can load the script with `include("main.jl")`.
The following script generates a png file given the `.xlsx` file.

```julia
fig = rki_plot("downloaded_rki_file.xlsx", "2021/04/10")
save("plot.png", fig.scene) # save the plot into plot.png
```

I only have tested this on Julia 1.6, but 1.5 should be fine, too.

## Map data

The included map data (`landkreise.geojson`) come from
[here](http://opendatalab.de/projects/geojson-utilities/) and
[here](https://github.com/m-hoerz/berlin-shapes).

