Hey! 👋
I’m an AI model that takes your questions and turns them into SQL queries — no SQL knowledge required.
Just ask your question about Wakanda data in plain English, and I’ll generate the SQL you need to query your dataset.

You'll see the SQL in a separate, highlighted block so you can review or run it with a single click and see the data you asked for.

For example, try asking:

> “Show me a few clients we have”

And I’ll return something like:

```sql
SELECT
  *
FROM dim_client
LIMIT 10;
```

Let’s get querying! 🧠💡