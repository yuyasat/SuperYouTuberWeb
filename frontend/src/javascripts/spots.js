import axios from 'axios'
import $ from 'jquery'
import _ from 'lodash'
import MarkerClusterer from 'node-js-marker-clusterer'

$(function() {
  const script = document.createElement('script');
  script.src="//maps.googleapis.com/maps/api/js?key=AIzaSyDVIj2EXnKBKcpcx-UZQGD3H7hK45bMMzE&libraries=places&callback=initMapWithSeachBox"

  document.getElementsByTagName('head')[0].appendChild(script);

//  const markerClusterJs = document.createElement('script')
//  markerClusterJs.src="https://developers.google.com/maps/documentation/javascript/examples/markerclusterer/markerclusterer.js"
//  document.getElementsByTagName('head')[0].appendChild(markerClusterJs);
})

function setSearchBox(map) {
  // Create the search box and link it to the UI element.
  const input = document.getElementById('pac-input');
  const searchBox = new google.maps.places.SearchBox(input);
 // map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

  map.addListener('bounds_changed', function() {
    searchBox.setBounds(map.getBounds());
  });

  let markers = [];
  searchBox.addListener('places_changed', function() {
    const places = searchBox.getPlaces();

    if (places.length == 0) {
      return;
    }

    // Clear out the old markers.
    markers.forEach(function(marker) {
      marker.setMap(null);
    });
    markers = [];

    // For each place, get the icon, name and location.
    const bounds = new google.maps.LatLngBounds();
    places.forEach(function(place) {
      if (!place.geometry) {
        console.log("Returned place contains no geometry");
        return;
      }
      const icon = {
        url: place.icon,
        size: new google.maps.Size(71, 71),
        origin: new google.maps.Point(0, 0),
        anchor: new google.maps.Point(17, 34),
        scaledSize: new google.maps.Size(25, 25)
      };

      // Create a marker for each place.
      markers.push(new google.maps.Marker({
        map: map,
        icon: icon,
        title: place.name,
        position: place.geometry.location
      }));

      if (place.geometry.viewport) {
        // Only geocodes have viewport.
        bounds.union(place.geometry.viewport);
      } else {
        bounds.extend(place.geometry.location);
      }
    });
    map.fitBounds(bounds);
  });
}

function getMovieLocations(map) {
  const url = `/internal/api/movie_location?path=${location.pathname}`
  const config = {
    method: 'get',
    params: {
     category_id: $('#map').data().categoryId,
    },
  };
  config.withCredentials = true;

  const successFn = (res) => {
    const locations = res.data

    const markers = locations.map(function(loc, i) {
      const marker = new google.maps.Marker({
        position: {  lat: loc.latitude, lng: loc.longitude },
      })

      const contentString = `
        <div class="thumbnail is-movie is-on-map">
          <a href="/movies/${loc.movie.id}" target="_blank"><img src="${loc.movie.mqdefault_url}"></a>
        </div>
      `
      const infoWindow = new google.maps.InfoWindow(Object.assign({}, {
        content: contentString,
        disableAutoPan: true,
      }, {}));
      ['mouseover', 'click'].forEach((e) => {
        marker.addListener(e, function() {
          infoWindow.open(map, marker)
        })
      })

      return marker
    })

    const markerCluster = new MarkerClusterer(map, markers, {
      styles: [{
        url: '/map_clusters/s1.png', width: 42, height: 45, textColor: '#fff',
      }, {
        url: '/map_clusters/s2.png', width: 45, height: 48, textColor: '#fff',
      }, {
        url: '/map_clusters/s3.png', width: 53, height: 56, textColor: '#fff',
      }, {
        url: '/map_clusters/s4.png', width: 62, height: 66, textColor: '#fff',
      }, {
        url: '/map_clusters/s5.png', width: 72, height: 77, textColor: '#fff',
      }]
    })
  }
  const errorFn = (error) => {
    console.log(error);
  }
  axios.get(url, config).then(successFn).catch(errorFn);
}

function initMapWithSeachBox() {
  const defaultCenter = { lat: 38.915671, lng: 104.737290 };
  const map = new google.maps.Map(document.getElementById('map'), {
    zoom: 3,
    center: defaultCenter,
  })

  setSearchBox(map)
  getMovieLocations(map)
}

window.initMapWithSeachBox = initMapWithSeachBox;
