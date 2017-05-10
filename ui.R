library(shiny)
source('fgamm4v22.R')

# Define UI for dataset viewer application
shinyUI(pageWithSidebar(
 # includeCSS('fgam.css'),
  # Application title.
  headerPanel("Comparison of Functional Regression Models"),
  # tags$head(tags$link(rel="stylesheet", type="text/css", href="mysidepanel.css")),
  # Sidebar with controls to select a dataset and specify the number
  # of observations to view. The helpText function is also used to 
  # include clarifying text. Most notably, the inclusion of a 
  # submitButton defers the rendering of output until the user 
  # explicitly clicks the button (rather than doing it immediately
  # when inputs change). This is useful if the computations required
  # to render output are inordinately time-consuming.
  sidebarPanel(
    tags$head(
      tags$style(type="text/css", "select { max-width: 200px; }"),
      tags$style(type="text/css", "textarea { max-width: 185px; }"),
      tags$style(type="text/css", ".jslider { max-width: 200px; }"),
      tags$style(type='text/css', ".well { max-width: 310px; }"),
      tags$style(type='text/css', ".span4 { max-width: 310px; }"),
      #includeScript("mathjaxFix.js", type="text/x-mathjax-config"),
      #includeScript("mathjax/MathJax.js")
      tags$script(type = "text/javascript", src = "https://c328740.ssl.cf1.rackcdn.com/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"),
      tags$script( "MathJax.Hub.Config({tex2jax: {inlineMath: [['$','$'], ['\\(','\\)']]}});", type='text/x-mathjax-config')
    ),
    HTML("<div style = 'padding-bottom: 10px;'>For an introduction to the FLM and FGAM, see the Research tab on my <a href='http://mwmclean.github.io/'>website</a> or the paper <a href='http://www.tandfonline.com/doi/abs/10.1080/10618600.2012.729985'>here</a>.</div>"),
    helpText(strong('Please send questions to:')),
    includeHTML('myemail.html'),
    h4(''),
    selectInput("dataset", "Choose a dataset:", 
                choices = c("Emissions", "DTI", "Tecator", "Temperature", "Precipitation")),
    
    #    numericInput("obs", "Number of obs. to highlight:", 8, min = 3, max = 12, step = 1),
    div(class='row',
        div(class="shiny-bound-input offset1", numericInput("obs", "Number of obs. to highlight:", 8, min = 3, max = 12, step = 1))
    ),
    tags$head(tags$style(type="text/css", "#obs { max-width: 185px; }")),
    #  tags$style(type='text/css', "#obs label { margin-left: 20px;}"),
    #     helpText("Note: while the data view will show only the specified",
    #              "number of observations, the fits will still be based",
    #              "on the full dataset."),
    helpText(strong('FLM Paramaters')),
    sliderInput("FLMnbf", "Number of basis functions to use for functional coefficient:", value = 15, min = 5, max = 25, step = 1),
    selectInput("sptypeFLM", "Method for Estimating Smoothing Parameters:", 
                choices = c("REML", "GCV", "Fixed")),
    conditionalPanel(condition = "input.sptypeFLM == 'Fixed'",
                     sliderInput("FLMsp", "base-10 log smoothing parameter for coefficient function", value = 1, min = -5, max = 10, step = 1,
                                 animate=TRUE)),
    helpText(strong('FGAM Paramaters')),
    uiOutput('xbfs'),
    uiOutput('tbfs'),
    #     sliderInput("FGAMxnbf", "Number of basis functions to use for x-axis basis for FGAM:", value = 10, min = 5, max = 10, step = 1),
    #     sliderInput("FGAMtnbf", "Number of basis functions to use for t-axis basis for FGAM:", value = 10, min = 5, max = 10, step = 1),
    selectInput("sptypeFGAM", "Method for Estimating Smoothing Parameters:", 
                choices = c("REML", "GCV", "Fixed")),
    conditionalPanel(condition = "input.sptypeFGAM == 'Fixed'",
                     sliderInput("FGAMxsp", "base-10 log smoothing parameter x-axis", value = 1, min = -5, max = 10, step = 1),
                     sliderInput("FGAMtsp", "base-10 log smoothing parameter t-axis", value = 1, min = -5, max = 10, step = 1)),
    radioButtons("plottype", "Type of plot for FGAM:",
                 c('persp', 'contour'), selected='persp'),
    #     radioButtons("pred", "Perform out of sample prediction?",
    #                  c('Yes', 'No'), selected='No'),
    checkboxInput("pred", "Perform out of sample prediction?", FALSE),
    
    uiOutput('n.test'),
    checkboxInput("htest", "Conduct hypothesis test?", FALSE),
    conditionalPanel(condition = "input.htest==1",
                     checkboxGroupInput('tests', 'Tests to use:', c('RLRT1', 'RLRT2', 'Bootstrap'),
                                        selected = 'RLRT1')),
    #    conditionalPanel(condition='input.pred',
    #                     numericInput("test.prop", "Proportion of samples to use for test set:", .2, min = 0, max = .5, step = .05),#),
    #conditionalPanel(condition='input.pred',
    #    helpText("Note: Selecting Zero for the Proportion of test samples results in one sample being used for testing.",
    #             "on the full dataset.")),
    actionButton('fitaction', "Fit Models")
  ),
  
  # Show a summary of the dataset and an HTML table with the requested
  # number of observations. Note the use of the h4 function to provide
  # an additional header above each output section.
  mainPanel(
    #    includeScript('toggle.js'),
    #includeHTML('index.html'),
    includeCSS('fgam.CSS'),
   # includeScript("imgAlt.js"),
    h4("Observed Functional Covariates"),
    verbatimTextOutput("summary"),
    plotOutput("matPlot"),
    h4(HTML("Functional Linear Model: $E(Y|X) = \\beta_0 + \\int\\beta(t)X(t)dt$")),
    conditionalPanel(condition = "input.fitaction", plotOutput('FLMplot')),
    conditionalPanel(condition = "!input.fitaction", HTML("<br //>")),
    h4("Functional Generalized Additive Model: $E(Y|X) = \\beta_0 + \\int F(X(t),t)dt$"),
    conditionalPanel(condition = "!input.fitaction", p(paste0("Choose Inputs on the left and then click 'Fit Models' ",
                                                              "to fit the FLM and FGAM using penalized splines."),
                                                       id = "Instructions")),
    conditionalPanel(condition = "input.fitaction", plotOutput('FGAMplot')),
    #     conditionalPanel(condition = "input.plottype=='persp'",
    #                      numericInput('theta','theta:', 0),
    #                      numericInput('phi','phi:', 30),
    #                      helpPopup('About', 'These define the viewing angles for the perspective plot (azimuth and coaltitude, respectively)',
    #                                            placement=c('right', 'top', 'left', 'bottom'),
    #                                            trigger='hover')), 
    conditionalPanel(condition = "input.plottype=='persp'&&input.fitaction",
                     div(class='row',
                         div(class="span2 offset1", numericInput('theta','theta:', value=10, step=5)),
                             #title = "These define the viewing angles for the perspective plot (azimuth and coaltitude, respectively)"),
                         div(class="span2", numericInput('phi','phi:', value=30, step=5),
                             #title = "These define the viewing angles for the perspective plot (azimuth and coaltitude, respectively)")
                             helpPopup('About', 'These define the viewing angles for the perspective plot (azimuth and coaltitude, respectively)',
                                       placement='right', trigger='hover'))
                     ),
                     tags$style(type="text/css", '#theta {width: 50px;}'),
                     tags$style(type="text/css", '#phi {width: 50px;}')
    ), 
    conditionalPanel(condition = "input.pred==1",
                     h4('Out-of-Sample Prediction Root Mean Square Error')),
    conditionalPanel(condition = "input.pred==1",
                     verbatimTextOutput("prederror")),
    conditionalPanel(condition = "input.htest==1",
                     h4('Hypothesis Test of H_0: FLM vs H_1: FGAM')),
   conditionalPanel(condition = "input.htest==1",
                    HTML("<div style = 'text-align: center; padding-bottom: 10px;'>For more information, see the paper on <a href = 'http://arxiv.org/abs/1310.5811' target='_blank'>arXiv</a></span></div>")),
    conditionalPanel(condition = "input.htest==1",
                     verbatimTextOutput("testres"))
  )
))
