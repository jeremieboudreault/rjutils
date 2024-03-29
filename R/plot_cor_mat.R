# plot_cor_mat.R


#' Work in progress : A custom function to plot a correlation matrix with ggplot2.
#'
#' @param x : Your dataset as a `data.table`.
#' @param title : The title of the plot.
#' @param rotate_x_labs : Rotation of x labels (default to `45`).
#' @param ... : Other arguments passed to [rjutils::jtheme()].
#'
#' @export

# Work in progress :  Function for ggplot correlation matrix. To be included
#                     in a future version of rjutils.
plot_cor_mat <- function(x, title = NULL, rotate_x_labs = 45, ...) {

    # Compute correlation.
    cormat <- cor(x, use = "complete.obs")

    # Keep lower triangle.
    cormat <- cormat * lower.tri(cormat)

    # Extract colnames.
    cn <- colnames(cormat)
    cormat <- data.table::setDT(as.data.frame(cormat))
    cormat$rn <- colnames(cormat)

    # Melt variables.
    cormat_melt <- data.table::setDT(data.table::melt(cormat, id.vars = "rn"))
    #cormat_melt <- cormat_melt[abs(cormat_melt$value) > 0.0000001, ]
    data.table::set(cormat_melt, j = "rn", value = factor(cormat_melt$rn, levels = rev(cn[-1])))
    data.table::set(cormat_melt, j = "variable", value = factor(cormat_melt$variable, levels = cn[-length(cn)]))
    data.table::set(cormat_melt, j = "value_t", value = round_trim(cormat_melt$value * 100, 1))
    data.table::set(cormat_melt, i = which(cormat_melt$value_t == "  0.0"), j = "value_t", value = "")
    cormat_melt <- cormat_melt[!is.na(rn), ]
    cormat_melt <- cormat_melt[!is.na(variable), ]

    # Return plot object.
    return(
        ggplot(cormat_melt, aes(x = variable, y = rn)) +
        geom_tile(aes(fill = value)) +
        geom_text(aes(label = value_t), color = "white", size = 3.5, family = "Source Sans Pro") +
        scale_y_discrete(expand = expansion(mult = c(0, 0))) +
        scale_x_discrete(expand = expansion(mult = c(0, 0))) +
        scale_fill_distiller(palette = "RdBu", direction = -1, limits = c(-1, 1))  +
        ggtitle(title) +
        labs(x = NULL, y = NULL, fill = "ρ =", alpha = 0) +
        jtheme(legend_pos = "right", rotate_x_labs = rotate_x_labs)
    )

}

