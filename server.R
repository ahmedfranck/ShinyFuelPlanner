library(shiny)

data(mtcars)

economy_model <- lm(mpg ~ wt + hp + cyl + am, data = mtcars)

function(input, output, session) {

  vehicle <- reactive({
    data.frame(
      wt = input$weight,
      hp = input$horsepower,
      cyl = as.numeric(input$cylinders),
      am = as.numeric(input$transmission)
    )
  })

  predicted_mpg_value <- reactive({
    raw_prediction <- predict(economy_model, newdata = vehicle())
    max(5, min(60, as.numeric(raw_prediction)))
  })

  total_distance <- reactive({
    multiplier <- if (isTRUE(input$round_trip)) 2 else 1
    input$distance * multiplier
  })

  trip_summary <- reactive({
    mpg <- predicted_mpg_value()
    gallons <- total_distance() / mpg
    cost <- gallons * input$fuel_price

    list(
      mpg = mpg,
      gallons = gallons,
      cost = cost
    )
  })

  output$predicted_mpg <- renderText({
    sprintf("%.1f", trip_summary()$mpg)
  })

  output$gallons_needed <- renderText({
    sprintf("%.1f", trip_summary()$gallons)
  })

  output$trip_cost <- renderText({
    sprintf("$%.2f", trip_summary()$cost)
  })

  output$economy_plot <- renderPlot({
    palette <- ifelse(mtcars$am == 1, "#0EA5E9", "#F97316")

    plot(
      mtcars$hp,
      mtcars$mpg,
      pch = 19,
      cex = 1.3 + mtcars$wt / 4,
      col = palette,
      xlab = "Horsepower",
      ylab = "Miles per gallon",
      main = "Observed cars and your estimated vehicle"
    )
    grid(col = "#E2E8F0")

    points(
      input$horsepower,
      predicted_mpg_value(),
      pch = 23,
      cex = 2.4,
      lwd = 2,
      bg = "#22C55E",
      col = "#14532D"
    )

    legend(
      "topright",
      legend = c("Automatic", "Manual", "Your estimate"),
      pch = c(19, 19, 23),
      pt.bg = c(NA, NA, "#22C55E"),
      col = c("#F97316", "#0EA5E9", "#14532D"),
      bty = "n"
    )
  })
}

