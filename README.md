# aldrich

A project that is an attempt to rehabilitate and generalize a data ingestion/importation service originally built for a retail, e-commerce platform. It aims to provide a robust solution for mapping intermediate representations of database records (CSV at the moment) to persisted data. The process allows simulation, validation, and control of the arrangement of the final data form. The ultimate goal is a project that is flexible enough to use in a pure-Ruby, Rails, or standalone application backed by data storage of your choice (as long as model representations can be accessed via Ruby).

Currently, there's not much here. This document will be updated with friendlier bits once the project is close to usable. Until then, what follows is disjointed bits of the original README file that still mostly apply.

# Process Workflow

This section contain general explanation for the internal implementation of the data compliation process. It includes flowchats outlining each level of the process. Not every tiny detail is included here as the service itself is rather complex and expansive.

Much more specific documentation as to API, purpose, and rationale is provided inside each ruby code file in the form of Tomdoc comments.

## General Importer Process

The top-most level of the Importer service workflow is reasonably straightforward. Simulation is mandatory when imports are performed via the Importer::Processors::Import class. The overall workflow can accept data from the web form or a RESTful request.

![Alt text](/lib/aldrich/doc/importer_process.png?raw=true "General Importer Process")

## Operation Group Handling

The primary iteration during an import is performed on each group code. Group codes are typically the SKU used for a Product, wether it parents Variants or not. All operations will be placed into separate sets by the group code and each invocation of Importer internals will operate on that set of Operation objects.

Generally speaking, error catching is done for each operation group. All other errors raised at this time will be considered unhandled, exceptional behavior. The structure of the service is such that the code used between simulations and imports differs as little as is possible, to allow simulations to be reasonable representations of the actual import process.

Currently simulation is unable to validate data against database-level validations. This results in some small circumstances where code validations raise no errors, but attempting to persist the same record results in an error from postgresql.

![Alt text](/lib/aldrich/doc/operation_group.png?raw=true "Operation Group Handling")

## Operation Group Translation

The Translation procedure for a group of Operation objects into actual ActiveRecord models is outlined here. It is a reasonably complicated process given that the dimentionality of our input data does not map 1-to-1 to our internal data structures. In addition, there is a great deal of domain knowledge dealing with business process, data policy, as well as association structure baked into each of the build procedures.

![Alt text](/lib/aldrich/doc/operation_translation.png?raw=true "Operation Group Translation")

## Model Build Procedure

The build procedure for each model instance is reasonably similar for each model. The logic that differs for each specific model has little to do with the overall procedure, and tends to only affect context or criteria for generating attributes or querying/detecting existing model instances in a given relation or table.

![Alt text](/lib/aldrich/doc/model_build_procedure.png?raw=true "Model Build Procedure")
