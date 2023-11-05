{
  // https://github.com/google/go-jsonnet/issues/554: '%g' % 0 causes overflow
  formatZero(value, formatStr='%g', ifZero='0'):: if value == 0 then ifZero else formatStr % value,
  formatZeroSigned(value):: self.formatZero(value, '%+g', '+0'),
}
