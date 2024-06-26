@react.component
let make = (~paymentId, ~disputeId) => {
  open LogTypes

  let disputesLogsUrl = `${Window.env.apiBaseUrl}/analytics/v1/api_event_logs?type=Dispute&payment_id=${paymentId}&dispute_id=${disputeId}`
  let webhooksLogsUrl = `${Window.env.apiBaseUrl}/analytics/v1/outgoing_webhook_event_logs?&payment_id=${paymentId}&dispute_id=${disputeId}`
  let connectorLogsUrl = `${Window.env.apiBaseUrl}/analytics/v1/connector_event_logs?payment_id=${paymentId}&dispute_id=${disputeId}`

  let urls = [
    {
      url: disputesLogsUrl,
      apiMethod: Get,
    },
    {
      url: webhooksLogsUrl,
      apiMethod: Get,
    },
    {
      url: connectorLogsUrl,
      apiMethod: Get,
    },
  ]

  <AuditLogUI id={paymentId} urls logType={#DISPUTE} />
}
