  Note: This is in reverse chronological order, so newer entries are added to the top.

## Skynet 0.2

EzerReader:
* EzerReader's user_comment is worked as Diagnosis decision. There are four types of decision, 'Positive'(/^[pP]/), 'Negative'(/^[nN]/), 'Suspended'(/^[sS]/), and 'Invalid'(others).

---

DB:
* New instance variable, 'decision', is added to Diagnosis to keep diagnosis decision measured by equipment or a health worker.

General (Gemfile):
* Gem e_markerclusterer is added to show infographic on the google map.

Google Map (app/assets/javascripts/google_maps.coffee, app/views/google_maps/index.html.erb):
* e_markerclusterer javascript is applied.
* legend setting is also applied to show legend box.
* marker data are located in '#map-data'.
