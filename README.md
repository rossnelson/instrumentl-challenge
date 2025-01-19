<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a name="readme-top"></a>

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/rossnelson/instrumentl-challenge">
    <img src="assets/logo.jpeg" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">SafeBite</h3>

  <p align="center">
    Ensuring Every Bite is Safe.
  </p>

  <p align="center">
    SafeBite is a restaurant inspection and food safety platform that provides
        insights into health inspections, violations, and compliance
        ratings. By aggregating and analyzing inspection data, SafeBite helps
        diners make informed choices and empowers restaurants to maintain the
        highest food safety standards.
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li>
      <a href="#usage">Usage</a>
      <ul>
        <li><a href="#import-the-sample-data">Import Sample Data</a></li>
        <li><a href="#api-endpoints">API Endpoints</a></li>
        <li><a href="#convenience-scripts">Convenience Scripts</a></li>
      </ul>
    </li>
    <li><a href="#roadmap">Roadmap</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

This project is organized into 2 primary features
* A data import service
* A REST API for data access

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

For this challenge locally accessible services and tools were
selected:

[![Postgresql][Postgresql]][Postgresql-url]  
[![Rails 7.2][Rails72]][Rails72-url]  
[![Ruby][Ruby]][Ruby-url]  
[![Dry-rb][Dry-rb]][Dry-rb-url]  
[![Activerecord][Activerecord]][Activerecord-url]  
[![ActiveJob][ActiveJob]][ActiveJob-url]  

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

Ensure the prerequisite tools are installed then review the Installation and
Usage sections below.

### Prerequisites

* ruby version 3.1.6 or greater
* docker desktop and compose


### Installation

Once the prerequisites have been met, at the root of the project run
`make -j`. It will start both the rails application, the docker
compose service, and tail the development logs. The rails application will be
available at `localhost:3000` and postgres will be available at
`localhost:5432`. 

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### Import the sample data

Run `make ingest`, this will executre the `ingest:files` rake task which calls 
the `Ingestion::ListFilesService` which will loop over the files in the
configured `ingest_dir` and pass each to the `Ingestion::FileService`. The
`Ingestion::FileService` will parse the CSV then group and validate the data.
Once processed, the data is ready for DB insertion.

### API endpoints

All endpoints are currently unauthenticated. In a production environment we
would expect some kind of authentication to be in place.

- `GET /metrics` - return total counts for each imported object
- `GET /locations` - list locations
- `GET /locations/:id` - Get a single location by id
- `GET /locations/:id/inspections` - list all inspections for a location

Since metrics are aggregates they are not paginated. But the resource endpoints
use Kaminari to paginate results. Add `page` and `size` query params to control
pagination. by default we only render the first 25 items. 

(I might regret this and have to remove it due to time constraints)
You can also use full text search by passing the search
parameter. for example `GET /locations?search=starbucks` will return all
locations with "starbucks" in the name.

### Executing Tests

From the root of the project run `make test`:

1. Waits fo rthe postgres db to become accessible
1. Creates and migrates the test db
1. Lints the codebase using `rubocop`
1. Executes unit test susing `rspec`

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [ ] More useful aggregates
    - top `n` violations
    - top `n` locations with violations
    - violations by location over time
    - violation serverity map
- [ ] Add authentication

Finalize plans on making the product production ready: 

TBD ![charts and diagrams](/assets/safebite.svg "charts and diagrams")


<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Ross Nelson - ross@simiancreative.com

Project Link: [https://github.com/rossnelson/instrumentl-challenge](https://github.com/ross_nelson/instrumentl-challenge)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[Postgresql]: https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white
[Postgresql-url]: https://www.postgresql.org/

[Rails72]: https://img.shields.io/badge/Rails_7.2-D30001?style=for-the-badge&logo=rubyonrails&logoColor=white
[Rails72-url]: https://rubyonrails.org/

[Ruby]: https://img.shields.io/badge/Ruby-CC342D?style=for-the-badge&logo=ruby&logoColor=white
[Ruby-url]: https://www.ruby-lang.org

[Dry-rb]: https://img.shields.io/badge/Dryrb-306d7d?style=for-the-badge&logo=rubygems&logoColor=white
[Dry-rb-url]: https://dry-rb.org

[Activerecord]: https://img.shields.io/badge/Activerecord-e9573f?style=for-the-badge&logo=rubygems&logoColor=white
[Activerecord-url]: https://rubygems.org/gems/activerecord/versions/5.0.0.1

[ActiveJob]: https://img.shields.io/badge/Activejob-5B3F8C?style=for-the-badge&logo=rubygems&logoColor=white
[ActiveJob-url]: https://guides.rubyonrails.org/active_job_basics.html
