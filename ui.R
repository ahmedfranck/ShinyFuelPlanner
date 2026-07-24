library(shiny)

fluidPage(
  tags$head(
    tags$link(
      rel = "stylesheet",
      type = "text/css",
      href = "custom.css"
    )
  ),

  div(
    class = "hero",
    h1("Road Trip Fuel Planner"),
    p("Estimate fuel economy, gallons, and trip cost from vehicle characteristics.")
  ),

  sidebarLayout(
    sidebarPanel(
      class = "control-card",
      h3("Describe your trip"),
      numericInput(
        "distance",
        "Trip distance (miles)",
        value = 500,
        min = 10,
        max = 5000,
        step = 10
      ),
      numericInput(
        "fuel_price",
        "Fuel price per gallon ($)",
        value = 3.50,
        min = 0.50,
        max = 10,
        step = 0.05
      ),
      h3("Describe your vehicle"),
      sliderInput(
        "weight",
        "Vehicle weight (1,000 lb)",
        min = 1.5,
        max = 5.5,
        value = 3.2,
        step = 0.1
      ),
      sliderInput(
        "horsepower",
        "Horsepower",
        min = 50,
        max = 350,
        value = 140,
        step = 5
      ),
      selectInput(
        "cylinders",
        "Number of cylinders",
        choices = c("4", "6", "8"),
        selected = "6"
      ),
      radioButtons(
        "transmission",
        "Transmission",
        choices = c("Automatic" = 0, "Manual" = 1),
        selected = 0,
        inline = TRUE
      ),
      checkboxInput(
        "round_trip",
        "Calculate a round trip",
        value = FALSE
      )
    ),

    mainPanel(
      fluidRow(
        column(
          4,
          div(
            class = "metric-card blue",
            span("Estimated economy"),
            h2(textOutput("predicted_mpg", inline = TRUE)),
            tags$small("miles per gallon")
          )
        ),
        column(
          4,
          div(
            class = "metric-card orange",
            span("Fuel required"),
            h2(textOutput("gallons_needed", inline = TRUE)),
            tags$small("gallons")
          )
        ),
        column(
          4,
          div(
            class = "metric-card green",
            span("Estimated fuel cost"),
            h2(textOutput("trip_cost", inline = TRUE)),
            tags$small("US dollars")
          )
        )
      ),

      div(
        class = "chart-card",
        h3("Where your vehicle sits"),
        p("The highlighted diamond is your estimate; circles are the 32 cars used to fit the model."),
        plotOutput("economy_plot", height = "380px")
      ),

      div(
        class = "documentation",
        h2("How to use this application"),
        tags$ol(
          tags$li("Enter the one-way trip distance and current fuel price."),
          tags$li("Adjust weight, horsepower, cylinders, and transmission to resemble your vehicle."),
          tags$li("Select round trip if you will return by the same route."),
          tags$li("Read the three estimates above. Every value updates automatically.")
        ),
        h3("What the calculation means"),
        p(
          "The app fits a multiple linear regression to R's built-in ",
          tags$code("mtcars"),
          " data. It predicts MPG from weight, horsepower, cylinders, and transmission. ",
          "Fuel required equals total distance divided by predicted MPG; cost equals gallons multiplied by fuel price."
        ),
        h3("Important limitations"),
        p(
          "This is an educational estimate, not a manufacturer rating. The dataset contains only 32 older vehicles. ",
          "Driving speed, terrain, weather, maintenance, and traffic are not included. Predictions are constrained ",
          "to a reasonable 5â€“60 MPG range."
        ),
        h3("Quick example"),
        p(
          "For a 500-mile trip in a 3,200 lb, 140-horsepower, six-cylinder automatic car, ",
          "leave the default settings in place. Change any control to compare scenarios."
        )
      )
    )
  ),

  tags$footer(
    "Built with Shiny using the mtcars dataset â€¢ Educational use only"
  )
)

