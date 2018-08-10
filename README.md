* Ruby version
    - 2.5.0

* Database creation
    - `bin/rails db:create`
    - `bin/rails db:migrate`
    - This service uses postgis extenstion. If it is difficult to install postgis, using docker is recommended.

* Database initialization
    - `bin/rails db:seed`

* Elasticserach Setup
    - `cd tools`
    - `docker-compose up`
    - Create Indices in rails console
        - `Movie.__elasticsearch__.create_index!`
    - Import Data
        - `Movie.__elasticsearch__.import(query: -> { includes(:categories, :video_artist) })`

* How to run the test suite
    - `RAILS_ENV=test bin/rspec spec`

* About frontend
    - If yarn is not installed, please install yarn. Check [here](https://yarnpkg.com/lang/en/docs/install/) to install yarn.
        - In the case of OSX, `brew install yarn`.
    - `cd frontend`
    - `npm install` or `yarn install`
    - Use command `yarn run build` or `yarn run watch` when developing.

* Deployment instructions
