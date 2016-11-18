  Note: This is in reverse chronological order, so newer entries are added to the top.

## Skynet 0.3

######2016. 11. 18
System
* bootstrap-datetimepicker gem replaced bootstrap-datepicker3 gem.

Device/Equipment/ErrorCode/Laboratory
* accounts with :data_manager or :device_manager are only accesible.

Diagnosis
* techinican instance variable is also securely stored.
* equipment instance variable should not be blank and creation request for invalid equipment returns fail.
* tranaction acts on a single database connection. For example, there is a redirection, transaction does not work correctly. In this situation, ActiveRecord::Rollback should be called manually. As a solution, we divided DB creation section and redirection section and applied transaction to DB creation section.

Notification
* NotificationError initialization bugs were fixed.
* a bug to generate exception was removed when there is no information, which should be ignored without any exception.

Person
* authorization should be required like Diagnosis (need validation).

Buddi/EzerReader/Frend
* devices should be accesible by diagnoses_controller only.

######2016. 11. 17
Diagnosis
* diagnosis validation requires remote_ip, which checks connected client IP. This validation is always failed because remote_ip is nil in migration.

Pundit
* EzerReaderPolicy and BuddiPolicy should be inherited from MachinePolicy.

######2016. 11. 16
System
* bootstrap-datepicker-rails gem was replaced by boostrap-datetimepicker-rails gem.
* jquery javascript was replaced by jquery3.
* all (almost) 'and' and 'or' were replaced by '&&' and '||' operators, respectively. 'and' and 'or' operators were strictly recommanded to be banned to clearify ruby coding style.
* addition blocks, :before_header and :after_footer were added in application layout.

Account/Device
* the bug that process performed with null device_license instance was fixed.
* test nil for null tag on @device_license (not nil but '') was fixed when an administrator grants directly.
* decline action name was changed to terminate (deactivate).
* redirection page was changed to modified account (for administrator) after termination.

Account/Management
* bugs on routes to remove roles or to terminate devices were fixed.

Account/Role
* bootstrap-datepicker was replaced by bootstrap-datetimepicker.
* the bug that process performed with null role instance was fixed.
* test nil for null tag on @@role (not nil but '') was fixed when an administrator grants directly.
* redirection page was changed to modified account (for administrator) after destroy.
* Google Place should be loaded syncronously to work with other google place based javascripts correctly and reloaded every time without caching. To archive, asyncronous (with deferred) javascript loading was removed and turbolinks were disabled (link with data: { turbolinks: false } parameter).

Google Map
* Google Map and Google Place should be loaded syncronously to work with other google map/place based javascripts correctly and reloaded every time without caching. To archive, asyncronous (with deferred) javascript loading was removed and turbolinks were disabled (link with data: { turbolinks: false } parameter).

######2016. 11. 14
System
* All types migration errors were removed on clean (empty) DB (should be careful for DB migration fail), which does not guarantee DB migration on used DB (durty DB?).
* Welcome page is prepared for front page (before and after login).

Pundit
* Authorization 
* Roll settings are connected with rollify gem.

Diagnosis
* Pubdit policy is applied with :data_manager
* device owner could access own measurements.

Google Map/AssayKit/QualityControlMaterial/Report
* Pubdit policy is applied with :data_manager.
* device owner could access surviallence map only for own measurements (not yet).

Role
* Rollify gem has been applied, which includes creating, requesting, applying, and removing roles.
* accounts/management_controller shows aquired roles. 

Device & DeviceLicense
* Device class manages collected devices information, and Accounts with related DeviceLicense can only access measurement data.
* accounts/management_controller shows aquired device_licenses.
* Device could be registered automatically after related measurement data has been registered.
* Pubdit policy is applied with :device_manager

Notification
* Bootstrap css has been applied to HTML email.
* Notification structure has been totally renewal. Follow is clearly devided two types, :responses and :notices. :responses means to require replying by additional system like email (or SMS). :notices means only noticable message.
* double updates on controllers was moved to model framework. before_save and after_save callback enable double updates.
* error message will be sent by exceptions (not complete yet), which needs more update to work perfectly.

######2016. 11. 11
* User and Specification MVC and relatives were removed. Account replaces User totally, which is based on Devise gem.
* account_validations and sessions controllers were removed.

######2016. 9. 4

* Skynet 0.3 is branched.
* Repository is transfered to BitBucket.
* SourceTree security token is generated in BitBucket.

## Skynet 0.2

######2016. 9. 1
System
* Devise gem has been applied in whole system.
* Devise_invitable gem gem has been applied, which subscription is allowed only forinvited user.
* Authorize and rollify gem has been applied in whole system.
* Lecacy codes are kept with deprecated tag to prevent unrecognized error occurring.

Buddi
* location information is set as Address, which is used to search Geolocation.

geocoder
* IP geolocation is received to call Maxmind(https://www.maxmind.com), which requires a fee by call.
* Geolocation information will be kept for 30 days in cache.


######2016. 8. 1
Google Map (app/assets/javascripts/google_maps.coffee, app/views/google_maps/index.html.erb):
* Grid size is increased (30 -> 50).
* Turbolinks should be disabled for full page refresh, which enables to show Google map (as expected?).

Buddi (app/models/buddi.rb):
* Default value of instance 'decision' is 'Influenza'.

###### 2016. 7. 25
Application (app/views/layouts/application.html.erb):
* A bug of not refreshing would be removed by adding '''<%= yield :scripts %>'''

Google Map (app/assets/javascripts/google_maps.coffee, app/assets/stylesheets/google_maps.scss, app/controllers/google_maps_controller.rb, app/views/google_maps/_assaylist.html.erb, app/views/google_maps/index.html.erb):
* 'bootstrap-slider-rails' is applied to show time slider (8 steps: D, W, M, Q, H, Y, 2, and whole). Current time scale is able to request huge amount of jobs to generate charts. In future, authorized account should be accessible.
* Marker selection rule is update to apply assay, equipment and measurement time.
* Assays and equipment selection forms are added.

Diagnosis (app/controllers/diagnoses_controller.rb, app/models/concerns/equipment_utils.rb):
* diagnosis_tag instance is generated by tag instance of each equipment

AssayKit (app/controllers/assay_kits_controller.rb, app/views/assay_kits/_form.html.erb):
* Target instance is added, which represents assay's target (target disease for example).

Frend (app/controllers/frends.rb):
* Assay kit should be found by equipment and kit name together

###### 2016. 7. 13
EzerReader:
* EzerReader's user_comment is worked as Diagnosis decision. There are four types of decision, 'Positive'(/^[pP]/), 'Negative'(/^[nN]/), 'Suspended'(/^[sS]/), and 'Invalid'(others).

DB:
* New instance variable, 'decision', is added to Diagnosis to keep diagnosis decision measured by equipment or a health worker.

General (Gemfile):
* Gem e_markerclusterer is added to show infographic on the google map.

Google Map (app/assets/javascripts/google_maps.coffee, app/views/google_maps/index.html.erb):
* e_markerclusterer javascript is applied.
* legend setting is also applied to show legend box.
* marker data are located in '#map-data'.
