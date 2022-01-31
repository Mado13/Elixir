export function formatApiData(data) {
  const response = {};
  const rows = [];
  const rowIterator = data.reports[0].data.rows;
  const metricsTotals = data.reports[0].data.totals[0].values;
  const dimensionName = data.reports[0].columnHeader.dimensions[0]
  const clicks =  data.reports[0].columnHeader.metricHeader.metricHeaderEntries[0].name
  const sessions = data.reports[0].columnHeader.metricHeader.metricHeaderEntries[1].name
  for (const [idx, row] of rowIterator.entries()) {
    rows[idx] = {
      [dimensionName]: row.dimensions[0],
      [clicks]: row.metrics[0].values[0],
      [sessions]: row.metrics[0].values[1]
    }
  }
  response.rows = rows
  response.totals = {
    [clicks]: metricsTotals[0],
    [sessions] : metricsTotals[1]
  }
  // response.rows = [{ [clicks]: 1, [sessions]: 1}]
  return response;
}
