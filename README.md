# Table AI

## What?

A proof of concept of using a large language model (LLM) to generate a bespoke "transformation machine" that uses an LLM to generate a series of "transform steps" to turn natural language into computation.

What follows is a description of a concrete example and implementation. I will return to the more general question later on.

**Specific problem:** What I want is the ability to ask [natural language questions](#natural-language-queries) of [tabular data](#faqs) and reliably get back accurate results over large datasets.

> A working example for the IMDB dataset coming soon.

## Why?

We want to have the best of both worlds: combine the ability to ask questions in a natural way with the computation accuracy and efficiency of traditional computation.

We want to be able to ask questions of data without having to write SQL queries or load the data into a database.

We want to be able to ask questions directly of data, even if that data is incomplete or badly formatted.

Let's take the IMDB dataset (1 million+ rows) for example:

<https://www.kaggle.com/datasets/octopusteam/full-imdb-dataset?resource=download>

We might want to find a movie set in a particular location from a particular time period with a certain rating.

| ID | Title | Type | Genres | Rating | Votes | Year |
|---|---|---|---|---:|---:|---:|
| tt0000009 | Miss Jerry | movie | Romance | 5.4 | 215 | 1894 |
| tt0000147 | The Corbett-Fitzsimmons Fight | movie | Documentary, News, Sport | 5.2 | 539 | 1897 |
| tt0000502 | Bohemios | movie |  | 4.4 | 18 | 1905 |
| tt0000574 | The Story of the Kelly Gang | movie | Action, Adventure, Biography | 6.0 | 941 | 1906 |

### How would we do this currently?

* We could manually read through the table finding things that look interesting. Given the table has over 1 million rows, this could be slow.
* We could load the data into a database and write a SQL query to get the data we want — perhaps if this is a common task and it proves worth the effort.
* We could load the data into an LLM and ask the AI the question. This can work, however it has some disadvantages. LLMs have limited context windows, they can make mistakes and they can be slow. See [Why not just use a LLM?](#why-not-just-use-a-llm).

We want the best of all worlds, and it is possible to have it with the right approach:

> **Turning natural language questions into fast, computable steps that can be run on the data directly.**

## System in action

![Table AI — how it works](images/how_it_works.png)

## How?

The process is roughly:

1. **Metadata Generation:** We programmatically inspect the structured data source and create metadata — information about columns, their types, and structure.

2. **LLM Generation of Steps:** We feed the LLM the natural language query, the metadata, and carefully crafted instructions. Instead of asking it for the final answer, we ask it to produce a set of [transformation steps](#transform-steps).

   For example, if you say:

   > "Get me all customers in Europe"

   The LLM might produce a filter step that includes a list of European countries.

3. **Execution on the Data:** Another engine (like a Python script with Pandas) runs these transformation steps on the data. If a step fails — say, dates are in inconsistent formats — we can feed those problematic rows back to the LLM and fix them.

4. **Result:** The output is a clean, final subset of data or an answer. The LLM only generated the instructions, so it isn't slowed down or confused by huge datasets.

---

# A DSL for Intelligence

I claim that table extraction is just one example of an application of using an LLM to generate accurate, computable steps from natural language.

These steps can be designed to better use the AI's generation capabilities, producing not an answer, but in effect a custom program for a specific question and data source.

These steps can be built up one by one to define certain capabilities on the data, such as filtering, sorting, grouping, joining, etc.

They do not have to be complete or complex, so you avoid the challenge of understanding a complete DSL such as SQL or AWK.

Predefined instructions are carefully crafted to leverage the AI model's natural language understanding capabilities, resulting in transformation rules that are:

* **More intuitive, flexible, and robust** to variations in data structure and query semantics compared to traditional DSL approaches such as directly generating Structured Query Language (SQL) commands.
* **Independent of data size.** We can disconnect the generation of rules from the size of the data. The system outlined here works in the same way for 10 rows or 10 million rows.
* **Better able to leverage model capabilities** to generate the correct rules. The transformations are robustly reproduced and each step is easy to debug.
* **Capable of surprising results**, such as [semantic expansion](#semantic-expansion). For example, asking a customer table for every customer in Europe can return a step containing:

```json
[
  "United Kingdom",
  "Germany",
  "France",
  "Italy",
  "Spain",
  "Netherlands",
  "Greece",
  "Sweden",
  "Poland",
  "Belgium",
  "Finland",
  "Denmark",
  "Ireland",
  "Portugal",
  "Austria",
  "Hungary",
  "Czech Republic",
  "Romania",
  "Bulgaria",
  "Slovakia",
  "Croatia",
  "Estonia",
  "Slovenia",
  "Latvia",
  "Lithuania",
  "Luxembourg",
  "Malta",
  "Cyprus"
]

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
