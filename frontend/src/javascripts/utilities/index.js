import _ from 'lodash';

export function queryToObject (queryString) {
  var query = (queryString || window.location.search).substring(1);
  if (!query) {
    return false;
  }
  return _.chain(query.split('&'))
    .map((params) => {
      const p = params.split('=');
      return [p[0], decodeURIComponent(p[1])];
    }).fromPairs().value();
}
