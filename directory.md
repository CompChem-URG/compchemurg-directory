+++
title = "Directory"
+++

# Directory

People from underrepresented groups working in and around computational chemistry, self-submitted by the people listed. See [Contribute](/contribute/) to add your own entry.

~~~
<div class="filter-bar">
  <input type="text" id="person-search" placeholder="Search by name, affiliation, or research area&hellip;">
  <select id="location-filter">
    <option value="">All locations</option>
    {{location_options}}
  </select>
</div>
<div id="person-listing">
  {{people_listing}}
</div>
<script src="/assets/js/filter.js"></script>
~~~
