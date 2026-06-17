package com.impactsiswa.model;

import java.math.BigDecimal;

public class LabelValue {
    private String label;
    private BigDecimal value;

    public LabelValue(String label, BigDecimal value) {
        this.label = label;
        this.value = value;
    }

    public String getLabel() { return label; }
    public BigDecimal getValue() { return value; }
}
