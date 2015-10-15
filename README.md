# Readme
Supplementary Material for Bergmann et al (accepted)

This Shiny app functions as supplementary material for Bergmann et al. (accepted). In our paper, we measured the interdisciplinarity between pairwise collaborations of authors in 425 journals, and subsequently ranked and compared the journal *Cognitive Science* to these other journals. For more details on the methodology, please see the paper and Bhat et al. (accepted).

Currently, an interactive version of the Shiny app is hosted on http://shiny.tillbergmann.com/apps/cogsci/. If you want to run the app yourself, clone the repository and run it in R with `runApp()`. You might have to install some additional packages and look up exactly how to run. Feel free to contact me if you have any questions.

The data is in several files:

* `raw_data2.csv`: All JSD measures for each journal.
* `avg_data2.csv`: JSD measures averaged across journals.
* `edges.csv`: The edge data for the *CogSci* author plot.
* `nodes.csv`: The node data for the *CogSci* author plot.

The Shiny app consists of `server.R` and `ui.R`, as usual.

#### References

Bergmann, T., Dale, R., Sattari, N., Heit, E. & Bhat, H. S. (accepted). The Interdisciplinarity of Collaborations in *Cognitive Science*. *Cognitive Science*.

Bhat, H. S., Huang, L.-H., Rodriguez, S., Dale, R., & Heit, E. (accepted). Citation Prediction Using Diverse Features. 3rd ICDM Workshop on Data Science and Big Data Analytics (DSBDA-2015) in IEEE ICDM ’15. [[PDF]](http://cognaction.org/rdmaterials/php.cv/pdfs/inproceedings/bhat_et_al_icdm.pdf)
