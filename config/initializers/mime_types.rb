# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register_alias "text/html", :iphone


Mime::Type.register "application/octet-stream", :shp
Mime::Type.register 'application/vnd.google-earth.kml+xml', :kml
Mime::Type.register 'application/xml', :fgdc
Mime::Type.register 'text/plain', :iso
Mime::Type.register 'application/zip', :zip
Mime::Type.register "application/x-amf", :amf
Mime::Type.register 'application/vnd.google-earth.kmz', :kmz

# Already registered by Rails
# Mime::Type.register "application/json", :json
# Mime::Type.register 'application/atom+xml', :atom
Mime::Type.register "application/x-sqlite3", :sqlite
Mime::Type.register "application/x-sqlite3", :spatialite
Mime::Type.register 'application/osm+xml', :osm

Mime::Type.register "text/plain", :txt
Mime::Type.register "application/vnd.mapnik.mml+xml", :mml
Mime::Type.register "application/vnd.mapnik.mss+xml", :mss
Mime::Type.register "application/pdf", :pdf
Mime::Type.register "image/png", :png
Mime::Type.register "application/vnd.ogc.wms_xml", :sld

Mime::Type.register "application/octet-stream", :shx
Mime::Type.register "application/octet-stream", :dbf
Mime::Type.register 'application/atomserv+xml', :atomserv
#Mime::Type.register "text/csv", :csv
