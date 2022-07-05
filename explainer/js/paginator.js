const current_page = (location.href.split("/").slice(-1)[0]).split(".")[0];

function isLocalPage(pageName) {
    return current_page === pageName;
}

function setNextPage(nextPage) {
    const next_page = document.createElement('div');
    const next_url = "/html/" + nextPage + ".html";
    next_page.classList.add("next");
    next_page.addEventListener("click", function () {
        window.location.replace(next_url);
    });
    document.body.appendChild(next_page);
}

function setLastPage(lastPage) {
    const last_page = document.createElement('div');
    const last_url = "/html/" + lastPage + ".html";
    last_page.classList.add("last");
    last_page.addEventListener("click", function () {
        window.location.replace(last_url);
    });
    document.body.appendChild(last_page);
}

const track_pages = [
    "01-about-this-track",
    "02-why-enable-tde",
    "03-about-tde",
    "04-track-contents"
];

for (let i = 0; i < track_pages.length; i++) {
    if (isLocalPage(track_pages[i])) {
        if (i == 0 && (i + 1) < track_pages.length) {
            setNextPage(track_pages[i + 1]);
        } else if (i == (track_pages.length - 1) && i >= 0) {
            setLastPage(track_pages[i - 1]);
        } else {
            setNextPage(track_pages[i + 1]);
            setLastPage(track_pages[i - 1]);
        }
    }
}