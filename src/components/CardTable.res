module TextCard = {
  @react.component
  let make = (~text) => {
    if text->LogicUtils.isNonEmptyString {
      <p className="break-words font-semibold">
        <HelperComponents.EllipsisText
          endValue=10 displayValue={text->LogicUtils.isNonEmptyString ? text : "N/A"} showCopy=false
        />
      </p>
    } else {
      React.string("-")
    }
  }
}

module ItemValue = {
  @react.component
  let make = (~cell: Table.cell, ~customMoneyStyle="", ~fontStyle="") => {
    open Table
    switch cell {
    | Label(x) => <LabelCell labelColor=x.color text=x.title fontStyle />
    | Text(x) => <TextCard text=x />
    | Currency(amount, currency) => <MoneyCell amount currency customMoneyStyle />
    | Date(timestamp) => <DateCell timestamp isCard=true textStyle=fontStyle hideTime=true />
    | StartEndDate(startDate, endDate) => <StartEndDateCell startDate endDate isCard=true />
    | Link(x) => <LinkCell data=x />
    | CustomCell(ele, _) => ele
    | Numeric(num, mapper) => <Numeric num mapper clearFormatting=false />
    | DeltaPercentage(value, delta) => <DeltaColumn value delta />
    | TrimmedText(text, width) => <TrimmedText text width highlightText="" hideShowMore=false />
    | _ => React.null
    }
  }
}

module CardDetails = {
  @react.component
  let make = (
    ~itemArray,
    ~heading: array<Table.header>,
    ~onRowClick,
    ~rowIndex,
    ~size=4,
    ~offset=0,
    ~isBorderEnabled=true,
    ~isAnalyticsModule,
  ) => {
    let {globalUIConfig: {font: {textColor}}} = React.useContext(ThemeProvider.themeContext)
    let onCardClick = _ => {
      switch onRowClick {
      | Some(fn) => fn(rowIndex + offset)
      | None => ()
      }
    }

    let (show, setshow) = React.useState(_ => true)

    let showMore = _ => {
      setshow(prev => !prev)
    }

    <div className="w-full lg:w-1/4 md:w-1/2" onClick=onCardClick>
      <div
        className={`flex justify-between flex-wrap dark:bg-jp-gray-lightgray_background bg-white my-2 px-4 ${isBorderEnabled
            ? "border border-jp-gray-500 dark:border-jp-gray-960 p-4 rounded"
            : ""} `}>
        {
          let itemArray = !show ? itemArray : Array.slice(itemArray, ~start=0, ~end=size)

          itemArray
          ->Array.mapWithIndex((cell, cellIndex) => {
            let key = Int.toString(cellIndex + offset) //webhooks UI
            switch heading[cellIndex] {
            | Some(label) =>
              if isAnalyticsModule {
                <div className="w-full flex jutify-end" key={cellIndex->Int.toString}>
                  <p className="mt-2 md:inline inline-block w-1/2 ">
                    {React.string(label.title)}
                  </p>
                  <div className="md:inline flex justify-end  w-1/2 break-all">
                    <ItemValue key cell />
                  </div>
                </div>
              } else {
                <div className="w-full" key={cellIndex->Int.toString}>
                  <p className="mt-2 md:inline inline-block w-1/2 ">
                    {React.string(label.title)}
                  </p>
                  <div className="md:inline inline-block w-1/2 ">
                    <ItemValue key cell />
                  </div>
                </div>
              }
            | None => React.null
            }
          })
          ->React.array
        }
        {if isAnalyticsModule {
          <div
            className={`flex justify-end ${textColor.primaryNormal} cursor-pointer`}
            onClick=showMore>
            {if itemArray->Array.length > size {
              show ? React.string("More") : React.string("Less")
            } else {
              React.null
            }}
          </div>
        } else {
          React.null
        }}
      </div>
    </div>
  }
}

@react.component
let make = (
  ~heading: array<Table.header>,
  ~rows,
  ~offset=0,
  ~onRowClick=?,
  ~size=4,
  ~isBorderEnabled=true,
  ~isAnalyticsModule=false,
) => {
  <div>
    <div className="overflow-auto flex flex-wrap">
      {rows
      ->Array.mapWithIndex((itemArray, rowIndex) => {
        <AddDataAttributes attributes=[("data-card-details", "cardDetails")]>
          <CardDetails
            key={(rowIndex + offset)->Int.toString}
            size
            itemArray
            isBorderEnabled
            heading
            onRowClick
            rowIndex
            offset
            isAnalyticsModule
          />
        </AddDataAttributes>
      })
      ->React.array}
    </div>
  </div>
}
