const ar_width = 16;
const ar_height = 9;

const paths = [
    {
        "id": 20,
        "class": "cell-span-3-3",
        "label": {
            "text": "Unauthorized User",
            "class": "cell-label-top"
        },
        "image": "hashi-container-3-3.svg",
        "splash_delay": 3,
        "modal": "modal1"
    },
    {
        "id": 21,
        "class": "cell-span-4-2",
        "label": {
            "text": "Unauthorized Access",
            "class": "cell-label-bottom",
            "color": "red"
        },
        "image": "hashi-container-4-2-1.svg",
        "splash_delay": 6,
        "modal": "modal2"
    },
    {
        "id": 19,
        "class": "cell-span-5-5",
        "label": {
            "text": "MS SQL Servers",
            "class": "cell-label-top"
        },
        "image": "hashi-container-5-5.svg",
        "splash_delay": 9,
        "modal": "modal3"
    },
    {
        "id": 22,
        "class": "cell-span-4-2",
        "label": {
            "text": "Unencrypted Data",
            "class": "cell-label-bottom",
            "color": "red"
        },
        "image": "hashi-container-4-2-2.svg",
        "splash_delay": 12,
        "modal": "modal4"
    }
];

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
    var grid_rows = Math.round(grid_columns / (ar_width / ar_height) - 1);
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

    paths.forEach(path => {
        const pathDiv = document.getElementById(path.id);
        const modal = document.getElementById(path.modal);
        pathDiv.classList.add(path.class);

        if (path.label.class == "cell-label-bottom") {
            const imageDiv = document.createElement("div");
            fetchSVG("/img/" + path.image).then(imageSVG => {
                imageDiv.appendChild(imageSVG.documentElement);
                pathDiv.appendChild(imageDiv);
            });
        }

        const labelDiv = document.createElement("div");
        labelDiv.classList.add(path.label.class);
        if (path.label.color) {
            labelDiv.style.color = path.label.color;
        }

        labelDiv.innerHTML = path.label.text;
        pathDiv.appendChild(labelDiv);

        if (path.label.class == "cell-label-top") {
            const imageDiv = document.createElement("div");
            fetchSVG("/img/" + path.image).then(imageSVG => {
                imageDiv.appendChild(imageSVG.documentElement);
                pathDiv.appendChild(imageDiv);
            });
        }

        pathDiv.style.setProperty("--splash-delay", path.splash_delay)

        pathDiv.addEventListener("mouseover", function () {
            modal.style.display = "block";
        });

        pathDiv.addEventListener("mouseout", function () {
            modal.style.display = "none";
        });

    })

};