import axios from 'axios'
import $ from 'jquery'

$(function() {
  var script = document.createElement('script');
  script.src="//maps.googleapis.com/maps/api/js?key=AIzaSyDVIj2EXnKBKcpcx-UZQGD3H7hK45bMMzE&libraries=places&callback=initMapSeachBox"
  document.getElementsByTagName('head')[0].appendChild(script);
})

function setEventListner(map) {
  map.addListener('dragend', function() {
    window.setTimeout(function() {
      refreshGoogleMap(map);
    }, 200);
  });
}

function set_markes(movies, previousMap) {
  const map = new google.maps.Map(document.getElementById('map'), {
    zoom: previousMap.getZoom(),
    center: previousMap.getCenter(),
  });

  movies.forEach(function(movie, i) {
    movie.locations.forEach(function(loc, j) {
      const lngLat = { lat: loc.latitude, lng: loc.longitude }
      const marker = new google.maps.Marker({
        position: lngLat,
        map: map
      });
      const contentString = `
        <img src="${movie.mqdefault_url}" width="20%">
      `
      const infoWindow = new google.maps.InfoWindow(Object.assign({}, {
        content: contentString,
        disableAutoPan: true,
      }, {}));
      infoWindow.open(map, marker)
    })
  })
  setEventListner(map);
}

function refreshGoogleMap(previousMap) {
  const url = '/internal/api/movie_location'
  const config = {
    method: 'get',
    params: {
      south_west_lat: previousMap.getBounds().getSouthWest().lat(),
      south_west_lng: previousMap.getBounds().getSouthWest().lng(),
      north_east_lat: previousMap.getBounds().getNorthEast().lat(),
      north_east_lng: previousMap.getBounds().getNorthEast().lng(),
    },
  };
  config.withCredentials = true;

  const successFn = (res) => {
    set_markes(res.data, previousMap)
  }
  const errorFn = (error) => {
    console.log(error);
  }
  axios.get(url, config).then(successFn).catch(errorFn);
}

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

function initMapSeachBox() {
  const defaultCenter = { lat: 38.915671, lng: 104.737290 };
  const map = new google.maps.Map(document.getElementById('map'), {
    zoom: 3,
    center: defaultCenter,
  });

  setSearchBox(map);

  // 中心が変わった = 検索結果の位置に移動した時だけイベントを発火する
  google.maps.event.addListener(map, 'center_changed', function() {
    window.setTimeout(function() {
      refreshGoogleMap(map)
    }, 200);
  });
}

function initMap() {
  var uluru = { lat:  35.646312, lng: 139.66994 };
  var map = new google.maps.Map(document.getElementById('map'), {
    zoom: 16,
    center: uluru
  });

  var marker = new google.maps.Marker({
    position: uluru,
    map: map
  });

  google.maps.event.addListener(map, 'bounds_changed', function() {
    window.setTimeout(function() {
      // refreshGoogleMap(map.getBounds())
    });
  });
  map.addListener('dragend', function(e) {
    window.setTimeout(function() {
      refreshGoogleMap(map); //.getCenter());
    }, 200);
  });
}

 window.initMap = initMap;
 window.initMapSeachBox = initMapSeachBox;
