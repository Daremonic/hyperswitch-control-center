open PaymentsProcessedTypes
open LogicUtils

let getStringFromVariant = value => {
  switch value {
  | Payment_Processed_Amount => "payment_processed_amount_in_usd"
  | Payment_Processed_Count => "payment_processed_count"
  | Payment_Processed_Amount_Without_Smart_Retries => "payment_processed_amount_without_smart_retries_in_usd"
  | Payment_Processed_Count_Without_Smart_Retries => "payment_processed_count_without_smart_retries"
  | Total_Payment_Processed_Amount => "total_payment_processed_amount_in_usd"
  | Total_Payment_Processed_Count => "total_payment_processed_count"
  | Total_Payment_Processed_Amount_Without_Smart_Retries => "total_payment_processed_amount_without_smart_retries_in_usd"
  | Total_Payment_Processed_Count_Without_Smart_Retriess => "total_payment_processed_count_without_smart_retries"
  | Time_Bucket => "time_bucket"
  }
}

let getVariantValueFromString = value => {
  switch value {
  | "payment_processed_amount_in_usd" => Payment_Processed_Amount
  | "payment_processed_count" => Payment_Processed_Count
  | "payment_processed_amount_without_smart_retries_in_usd" =>
    Payment_Processed_Amount_Without_Smart_Retries
  | "payment_processed_count_without_smart_retries" => Payment_Processed_Count_Without_Smart_Retries
  | "total_payment_processed_amount_in_usd" => Total_Payment_Processed_Amount
  | "total_payment_processed_count" => Total_Payment_Processed_Count
  | "total_payment_processed_amount_without_smart_retries_in_usd" =>
    Total_Payment_Processed_Amount_Without_Smart_Retries
  | "total_payment_processed_count_without_smart_retries" =>
    Total_Payment_Processed_Count_Without_Smart_Retriess
  | "time_bucket" | _ => Time_Bucket
  }
}

let isAmountMetric = key => {
  switch key->getVariantValueFromString {
  | Payment_Processed_Amount
  | Payment_Processed_Amount_Without_Smart_Retries
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Amount_Without_Smart_Retries => true
  | _ => false
  }
}

let paymentsProcessedMapper = (
  ~params: NewAnalyticsTypes.getObjects<JSON.t>,
): LineGraphTypes.lineGraphPayload => {
  open LineGraphTypes
  open NewAnalyticsUtils
  let {data, xKey, yKey} = params
  let comparison = switch params.comparison {
  | Some(val) => Some(val)
  | None => None
  }
  let primaryCategories = data->getCategories(0, yKey)
  let secondaryCategories = data->getCategories(1, yKey)

  let lineGraphData = data->getLineGraphData(~xKey, ~yKey, ~isAmount=xKey->isAmountMetric)
  let title = {
    text: "Payments Processed",
  }

  open NewAnalyticsTypes
  let metricType = switch xKey->getVariantValueFromString {
  | Payment_Processed_Amount => Amount
  | _ => Volume
  }

  let tooltipFormatter = tooltipFormatter(
    ~secondaryCategories,
    ~title="Payments Processed",
    ~metricType,
    ~comparison,
  )

  {
    categories: primaryCategories,
    data: lineGraphData,
    title,
    yAxisMaxValue: None,
    tooltipFormatter,
  }
}

let visibleColumns = [Time_Bucket]

let tableItemToObjMapper: Dict.t<JSON.t> => paymentsProcessedObject = dict => {
  open NewAnalyticsUtils
  {
    payment_processed_amount_in_usd: dict->getAmountValue(
      ~id=Payment_Processed_Amount->getStringFromVariant,
    ),
    payment_processed_count: dict->getInt(Payment_Processed_Count->getStringFromVariant, 0),
    payment_processed_amount_without_smart_retries_in_usd: dict->getAmountValue(
      ~id=Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant,
    ),
    payment_processed_count_without_smart_retries: dict->getInt(
      Payment_Processed_Count_Without_Smart_Retries->getStringFromVariant,
      0,
    ),
    total_payment_processed_amount_in_usd: dict->getAmountValue(
      ~id=Total_Payment_Processed_Amount->getStringFromVariant,
    ),
    total_payment_processed_count: dict->getInt(
      Total_Payment_Processed_Count->getStringFromVariant,
      0,
    ),
    total_payment_processed_amount_without_smart_retries_in_usd: dict->getAmountValue(
      ~id=Total_Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant,
    ),
    total_payment_processed_count_without_smart_retries: dict->getInt(
      Total_Payment_Processed_Count_Without_Smart_Retriess->getStringFromVariant,
      0,
    ),
    time_bucket: dict->getString(Time_Bucket->getStringFromVariant, "NA"),
  }
}

let getObjects: JSON.t => array<paymentsProcessedObject> = json => {
  json
  ->LogicUtils.getArrayFromJson([])
  ->Array.map(item => {
    tableItemToObjMapper(item->getDictFromJsonObject)
  })
}

let getHeading = colType => {
  switch colType {
  | Payment_Processed_Amount =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Amount->getStringFromVariant,
      ~title="Amount",
      ~dataType=TextType,
    )
  | Payment_Processed_Amount_Without_Smart_Retries =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant,
      ~title="Amount",
      ~dataType=TextType,
    )
  | Payment_Processed_Count =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Count->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Payment_Processed_Count_Without_Smart_Retries =>
    Table.makeHeaderInfo(
      ~key=Payment_Processed_Count_Without_Smart_Retries->getStringFromVariant,
      ~title="Count",
      ~dataType=TextType,
    )
  | Time_Bucket =>
    Table.makeHeaderInfo(~key=Time_Bucket->getStringFromVariant, ~title="Date", ~dataType=TextType)

  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Total_Payment_Processed_Amount_Without_Smart_Retries
  | Total_Payment_Processed_Count_Without_Smart_Retriess =>
    Table.makeHeaderInfo(~key="", ~title="", ~dataType=TextType)
  }
}

let getCell = (obj, colType): Table.cell => {
  open NewAnalyticsUtils
  switch colType {
  | Payment_Processed_Amount => Text(obj.payment_processed_amount_in_usd->valueFormatter(Amount))
  | Payment_Processed_Amount_Without_Smart_Retries =>
    Text(obj.payment_processed_amount_without_smart_retries_in_usd->valueFormatter(Amount))
  | Payment_Processed_Count => Text(obj.payment_processed_count->Int.toString)
  | Payment_Processed_Count_Without_Smart_Retries =>
    Text(obj.payment_processed_count_without_smart_retries->Int.toString)
  | Time_Bucket => Text(obj.time_bucket->formatDateValue(~includeYear=true))
  | Total_Payment_Processed_Amount
  | Total_Payment_Processed_Count
  | Total_Payment_Processed_Amount_Without_Smart_Retries
  | Total_Payment_Processed_Count_Without_Smart_Retriess =>
    Text("")
  }
}

open NewAnalyticsTypes
let dropDownOptions = [
  {label: "By Amount", value: Payment_Processed_Amount->getStringFromVariant},
  {label: "By Count", value: Payment_Processed_Count->getStringFromVariant},
]

let tabs = [{label: "Daily", value: (#G_ONEDAY: granularity :> string)}]

let defaultMetric = {
  label: "By Amount",
  value: Payment_Processed_Amount->getStringFromVariant,
}

let defaulGranularity = {
  label: "Daily",
  value: (#G_ONEDAY: granularity :> string),
}

let getKeyForModule = (key, ~isSmartRetryEnabled) => {
  let field = key->getVariantValueFromString
  switch (field, isSmartRetryEnabled) {
  | (Payment_Processed_Amount, Smart_Retry) => Payment_Processed_Amount
  | (Payment_Processed_Count, Smart_Retry) => Payment_Processed_Count
  | (Payment_Processed_Amount, Default) => Payment_Processed_Amount_Without_Smart_Retries
  | (Payment_Processed_Count, Default) | _ => Payment_Processed_Count_Without_Smart_Retries
  }->getStringFromVariant
}

let getMetaDataMapper = (key, ~isSmartRetryEnabled) => {
  let field = key->getVariantValueFromString
  switch (field, isSmartRetryEnabled) {
  | (Payment_Processed_Amount, Smart_Retry) => Total_Payment_Processed_Amount
  | (Payment_Processed_Count, Smart_Retry) => Total_Payment_Processed_Count
  | (Payment_Processed_Amount, Default) => Total_Payment_Processed_Amount_Without_Smart_Retries
  | (Payment_Processed_Count, Default) | _ => Total_Payment_Processed_Count_Without_Smart_Retriess
  }->getStringFromVariant
}

let isSmartRetryEnbldForPmtProcessed = isEnabled => {
  switch isEnabled {
  | Smart_Retry => [Payment_Processed_Amount, Payment_Processed_Count]
  | Default => [
      Payment_Processed_Amount_Without_Smart_Retries,
      Payment_Processed_Count_Without_Smart_Retries,
    ]
  }
}

let modifyQueryData = data => {
  let dataDict = Dict.make()

  data->Array.forEach(item => {
    let valueDict = item->getDictFromJsonObject
    let time = valueDict->getString(Time_Bucket->getStringFromVariant, "")

    switch dataDict->Dict.get(time) {
    | Some(prevVal) => {
        let key = Payment_Processed_Count->getStringFromVariant
        let paymentProcessedCount = valueDict->getInt(key, 0)
        let prevProcessedCount = prevVal->getInt(key, 0)
        let key = Payment_Processed_Amount->getStringFromVariant
        let paymentProcessedAmount = valueDict->getFloat(key, 0.0)
        let prevProcessedAmount = prevVal->getFloat(key, 0.0)
        let key = Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant
        let paymentProcessedAmountWithoutSmartRetries = valueDict->getFloat(key, 0.0)
        let prevProcessedAmountWithoutSmartRetries = prevVal->getFloat(key, 0.0)
        let key = Payment_Processed_Count_Without_Smart_Retries->getStringFromVariant
        let paymentProcessedCountWithoutSmartRetries = valueDict->getInt(key, 0)
        let prevProcessedCountWithoutSmartRetries = prevVal->getInt(key, 0)

        let totalPaymentProcessedCount = paymentProcessedCount + prevProcessedCount
        let totalPaymentProcessedAmount = paymentProcessedAmount +. prevProcessedAmount
        let totalPaymentProcessedAmountWithoutSmartRetries =
          paymentProcessedAmountWithoutSmartRetries +. prevProcessedAmountWithoutSmartRetries
        let totalPaymentProcessedCountWithoutSmartRetries =
          paymentProcessedCountWithoutSmartRetries + prevProcessedCountWithoutSmartRetries

        prevVal->Dict.set(
          Payment_Processed_Count->getStringFromVariant,
          totalPaymentProcessedCount->JSON.Encode.int,
        )
        prevVal->Dict.set(
          Payment_Processed_Amount->getStringFromVariant,
          totalPaymentProcessedAmount->JSON.Encode.float,
        )
        prevVal->Dict.set(
          Payment_Processed_Amount_Without_Smart_Retries->getStringFromVariant,
          totalPaymentProcessedAmountWithoutSmartRetries->JSON.Encode.float,
        )
        prevVal->Dict.set(
          Payment_Processed_Count_Without_Smart_Retries->getStringFromVariant,
          totalPaymentProcessedCountWithoutSmartRetries->JSON.Encode.int,
        )

        dataDict->Dict.set(time, prevVal)
      }
    | None => dataDict->Dict.set(time, valueDict)
    }
  })

  dataDict->Dict.valuesToArray->Array.map(JSON.Encode.object)
}
