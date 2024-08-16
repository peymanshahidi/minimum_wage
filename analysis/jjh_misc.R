write.image <- function(filename, g, width = 5, height = 5,  format = "png"){
  "Writes a passed ggplot, g, to the filename. The default format is png."
  do.call(format, list(filename, width, height))
   print(g)
  dev.off()
}

writeEntry <- function(key, value, parameter.file){
    # Writes a single entry back to the parameter file. 
    line <- paste0("\\newcommand{", key, "}{", value, "}")
    write(line, parameter.file, ncolumns = 1, append = TRUE)
}

WriteListToParamFile <- function(full.list, file.name){
    for(key in names(full.list)){
        writeEntry(key, full.list[key], file.name)
    }
}

convertToListEntry <- function(line){
    first.pattern <- "\\{.*\\}\\{"
    m <- regexpr(first.pattern, line)
    key <- gsub("[}{]", "", regmatches(line, m))

    second.pattern <- "\\}\\{.*\\}"
    m <- regexpr(second.pattern, line)
    value <- gsub("[}{]", "", regmatches(line, m))
    l = list()
    l[key] = value
    l 
}

ReadParamFile <- function(file.name){
    # returns the contents of a parameter file as a list 
    lines <- readLines(file.name, file.info(file.name)$size)
    do.call("c", lapply(lines, convertToListEntry))
}

genParamAdder <- function (parameter.file) {
    if (file.exists(parameter.file)) {
        file.remove(parameter.file)
    }
    f <- function(name, value) {
        ## Check if file exists already 
        if (file.exists(parameter.file)) {
            l <- ReadParamFile(parameter.file)
            # if this value was already in the params file
            if(name %in% names(l)){
                print(paste0("Updated: ", name, " from ", l[name], " to ", value))
            }
            l[name] = value
            file.remove(parameter.file)
            WriteListToParamFile(l, parameter.file)
        } else { 
            line <- paste0("\\newcommand{", name, "}{", value, "}")
            write(line, parameter.file, ncolumns = 1, append = TRUE)
        }
    }
    f
}


writeImage <- function (g, file.name.no.ext, width = 15, height = 8, path = "../../writeup/plots/"
          , position = "h", line.width = "0.8", caption = "", notes = "", include.tex.wrapper = FALSE, svg.include = FALSE){
  png.width <- width * 72
  png.height <- height * 72
  png.file.name <- paste0(path, file.name.no.ext, ".png")
  pdf.width <- width
  pdf.height <- height
  pdf.file.name <- paste0(path, file.name.no.ext, ".pdf")
  svg.file.name <- paste0(path, file.name.no.ext, ".svg")
  pdf.file.name.no.path <- paste0(file.name.no.ext, ".pdf")
  write.image(png.file.name, g, format = "png", width = png.width, 
              height = png.height)
  write.image(pdf.file.name, g, format = "pdf", width = pdf.width, 
              height = pdf.height)
  if (svg.include){
      write.image(svg.file.name, g, format = "svg", width = pdf.width, 
                  height = pdf.height)
  }   
  if (include.tex.wrapper){
      tex.file.name <- paste0(path, file.name.no.ext, ".tex")
      replacements = list("<<POSITION>>" = position
                        , "<<WIDTH>>" = line.width
                        , "<<CAPTION>>" = caption
                        , "<<LABEL>>" = file.name.no.ext
                        , "<<FILE>>" = pdf.file.name.no.path
                        , "<<NOTES>>" = notes
                          )		
      cat(render("\\begin{figure}[<<POSITION>>]
             \\centering
             \\begin{minipage}{<<WIDTH>> \\linewidth}
             \\caption{<<CAPTION>>} \\label{fig:<<LABEL>>}
             \\includegraphics[width = \\linewidth]{./plots/<<FILE>>}
{\\footnotesize \\emph{Notes:} <<NOTES>>} 
             \\end{minipage} 
             \\end{figure}", replacements), file= tex.file.name)
  }
}


starLabel <- function(p) {
    cuts <- c(0.001, 0.01, 0.05, 0.10)
    if( any(p <= cuts) ){
        symbol <- c("***", "**", "*", "$\\dagger$")[p <= cuts][1]
    } else {
        symbol <- ""
    }
    symbol 
}

AddTableNote <- function(stargazer.object, out.file, note, adjust = 3, table.type = "table"){
    "Adds a table note to a stargazer table. It assumes that the
     last three lines of stargazer output are useless."
    n <- length(stargazer.object)
    write(stargazer.object[1:(n - adjust)], out.file)
    write(c("\\end{tabular}"), out.file, append = TRUE)
    write(note, out.file, append = TRUE)
    write(c(paste0("\\end{", table.type, "}")), out.file, append = TRUE)
} 
