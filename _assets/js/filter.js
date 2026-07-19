(function () {
  var searchInput = document.getElementById("person-search");
  var locationSelect = document.getElementById("location-filter");
  var listing = document.getElementById("person-listing");

  if (!searchInput || !listing) return;

  var cards = Array.prototype.slice.call(listing.querySelectorAll(".person-card"));

  function cardText(card) {
    var name = card.querySelector(".person-name");
    var affiliation = card.querySelector(".person-affiliation");
    return [
      name ? name.textContent : "",
      affiliation ? affiliation.textContent : "",
      card.getAttribute("data-research-areas") || "",
    ]
      .join(" ")
      .toLowerCase();
  }

  function applyFilters() {
    var query = searchInput.value.trim().toLowerCase();
    var location = locationSelect ? locationSelect.value : "";
    var visibleCount = 0;

    cards.forEach(function (card) {
      var matchesQuery = query === "" || cardText(card).indexOf(query) !== -1;
      var matchesLocation = location === "" || card.getAttribute("data-location") === location;
      var visible = matchesQuery && matchesLocation;
      card.classList.toggle("is-hidden", !visible);
      if (visible) visibleCount += 1;
    });

    var noResults = listing.querySelector(".no-results");
    if (visibleCount === 0) {
      if (!noResults) {
        noResults = document.createElement("p");
        noResults.className = "no-results";
        noResults.textContent = "No matching entries.";
        listing.appendChild(noResults);
      }
    } else if (noResults) {
      noResults.remove();
    }
  }

  searchInput.addEventListener("input", applyFilters);
  if (locationSelect) locationSelect.addEventListener("change", applyFilters);
})();
