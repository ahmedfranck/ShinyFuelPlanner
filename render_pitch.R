input <- readLines("pitch.Rpres", warn = FALSE)

separator <- which(grepl("^={10,}$", input))
slides <- lapply(seq_along(separator), function(i) {
  title_line <- separator[i] - 1
  body_start <- separator[i] + 1
  body_end <- if (i < length(separator)) separator[i + 1] - 2 else length(input)
  c(input[title_line], "", input[body_start:body_end])
})

render_chunk <- function(lines) {
  output <- character()
  in_chunk <- FALSE
  code <- character()

  for (line in lines) {
    if (grepl("^```\\{r", line)) {
      in_chunk <- TRUE
      code <- character()
    } else if (in_chunk && grepl("^```$", line)) {
      captured <- capture.output({
        evaluated <- tryCatch(
          withVisible(eval(parse(text = code), envir = .GlobalEnv)),
          error = function(e) stop("Pitch code error: ", conditionMessage(e))
        )
        if (isTRUE(evaluated$visible)) print(evaluated$value)
      })
      output <- c(
        output,
        "<pre class=\"r-code\"><code>",
        htmltools::htmlEscape(paste(code, collapse = "\n")),
        "</code></pre>",
        "<pre class=\"r-output\"><code>",
        htmltools::htmlEscape(paste(captured, collapse = "\n")),
        "</code></pre>"
      )
      in_chunk <- FALSE
    } else if (in_chunk) {
      code <- c(code, line)
    } else {
      output <- c(output, line)
    }
  }
  output
}

markdown_to_html <- function(lines) {
  html <- character()
  in_list <- FALSE
  in_raw_block <- FALSE

  for (line in lines) {
    if (grepl("^<pre", line) || in_raw_block) {
      if (in_list) {
        html <- c(html, "</ul>")
        in_list <- FALSE
      }
      html <- c(html, line)
      if (grepl("^<pre", line)) in_raw_block <- TRUE
      if (grepl("</pre>$", line)) in_raw_block <- FALSE
      next
    }

    escaped <- gsub("&", "&amp;", line, fixed = TRUE)
    escaped <- gsub("<", "&lt;", escaped, fixed = TRUE)
    escaped <- gsub(">", "&gt;", escaped, fixed = TRUE)
    escaped <- gsub("\\*\\*(.+?)\\*\\*", "<strong>\\1</strong>", escaped)
    escaped <- gsub("`([^`]+)`", "<code>\\1</code>", escaped)

    if (grepl("^[-] ", escaped)) {
      if (!in_list) {
        html <- c(html, "<ul>")
        in_list <- TRUE
      }
      html <- c(html, paste0("<li>", sub("^[-] ", "", escaped), "</li>"))
    } else if (nzchar(trimws(escaped))) {
      if (in_list) {
        html <- c(html, "</ul>")
        in_list <- FALSE
      }
      if (grepl("^\\$\\$", escaped)) {
        html <- c(html, paste0("<div class=\"formula\">", escaped, "</div>"))
      } else {
        html <- c(html, paste0("<p>", escaped, "</p>"))
      }
    }
  }
  if (in_list) html <- c(html, "</ul>")
  html
}

sections <- character()
for (i in seq_along(slides)) {
  slide <- slides[[i]]
  title <- trimws(slide[1])
  body <- slide[-c(1, 2)]

  if (i == 1) {
    metadata <- body[grepl("^(author|date):", body)]
    body <- body[!grepl("^(author|date|width|height):", body)]
  } else {
    metadata <- character()
  }

  body <- render_chunk(body)
  body_html <- markdown_to_html(body)

  sections <- c(
    sections,
    sprintf(
      '<section class="slide%s"><div class="slide-number">%d / 5</div><h1>%s</h1>%s%s</section>',
      if (i == 1) " title-slide" else "",
      i,
      title,
      if (length(metadata)) paste0("<p class=\"metadata\">", paste(metadata, collapse = " â€¢ "), "</p>") else "",
      paste(body_html, collapse = "\n")
    )
  )
}

stopifnot(length(sections) == 5)

template <- paste(readLines("pitch_template.html", warn = FALSE), collapse = "\n")
page <- sub("<!-- SLIDES -->", paste(sections, collapse = "\n"), template, fixed = TRUE)
writeLines(page, "index.html", useBytes = TRUE)

cat("Rendered", length(sections), "slides to index.html\n")

