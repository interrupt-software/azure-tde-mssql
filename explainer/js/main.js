const ar_width = 16;
const ar_height = 9;

function getDivSize(classdef) {
    var w = parseInt(classdef.slice(10, 11));
    var h = parseInt(classdef.slice(12));
    return w * h;
}

const parser = new DOMParser();

async function fetchSVG(svg_name) {
    const response = await fetch(svg_name);
    const svgText = await response.text();
    const svgDoc = parser.parseFromString(svgText, 'text/xml');
    return svgDoc;
}

window.onload = function () {

    var styles = getComputedStyle(document.documentElement);
    var grid_columns = styles.getPropertyValue("--grid-columns");
    var grid_rows = Math.round(grid_columns / (ar_width / ar_height));
    document.documentElement.style.setProperty("--grid-rows", grid_rows);

    var offset = 0;

    paths.forEach(path => {
        offset += getDivSize(path.class);
    })

    var matrix_size = grid_columns * grid_rows;
    var matrix_true_size = matrix_size - offset;

    const matrix = document.getElementById("matrix");

    for (let i = 0; i < grid_rows; i++) {
        for (let j = 0; j < grid_columns && (i * grid_columns + j <= matrix_true_size); j++) {
            var newDiv = document.createElement("div");
            newDiv.id = i * grid_columns + j;
            newDiv.classList.add("cell");
            // newDiv.innerHTML = newDiv.id;
            matrix.appendChild(newDiv);
        }
    }

    // If we have a paths map, load them in sequence
    // TO DO: Create class module to make this process
    // easier for the developer.

    if (paths) {
        paths.forEach(path => {
            const pathDiv = document.getElementById(path.id);
            pathDiv.classList.add(path.class);

            if (path.boxtype) {
                pathDiv.classList.add(path.boxtype);
                console.log(path.boxtype)
            }

            // We want the image above the main label

            if (path.label) {
                if (path.image && path.label.class == "cell-label-bottom") {
                    const imageDiv = document.createElement("div");
                    fetchSVG("/img/" + path.image).then(imageSVG => {
                        imageDiv.appendChild(imageSVG.documentElement);
                        pathDiv.appendChild(imageDiv);
                    });
                }

                // This is the label. Check to ensure label exists.

                const labelDiv = document.createElement("div");
                labelDiv.classList.add(path.label.class);
                if (path.label.color) {
                    labelDiv.style.color = path.label.color;
                }
                labelDiv.innerHTML = path.label.text;
                pathDiv.appendChild(labelDiv);

                // if we want the image after the main label

                if (path.image && path.label.class == "cell-label-top") {
                    const imageDiv = document.createElement("div");
                    fetchSVG("/img/" + path.image).then(imageSVG => {
                        imageDiv.appendChild(imageSVG.documentElement);
                        pathDiv.appendChild(imageDiv);
                    });
                }
            } else if (path.image) {
                const imageDiv = document.createElement("div");
                fetchSVG("/img/" + path.image).then(imageSVG => {
                    imageDiv.appendChild(imageSVG.documentElement);
                    pathDiv.appendChild(imageDiv);
                });
            }

            pathDiv.style.setProperty("--splash-delay", path.splash_delay)

            // If we have an overlay modal in the path map

            if (path.modal) {
                const modal = document.getElementById(path.modal);

                pathDiv.addEventListener("mouseover", function () {
                    modal.style.display = "block";
                });

                pathDiv.addEventListener("mouseout", function () {
                    modal.style.display = "none";
                });
            }

        })
    }



};