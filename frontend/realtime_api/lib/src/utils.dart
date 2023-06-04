
class PrimitiveWrapper {
  var value;
  PrimitiveWrapper(this.value);
}

void replaceValueInMap(PrimitiveWrapper data, dynamic updateData, List<String> pathComp) {
  while (pathComp.length > 1) {
    PrimitiveWrapper tmp = PrimitiveWrapper(data.value[pathComp[0]]);
    pathComp.removeAt(0);
    data = tmp;
  }
  if (updateData == null) {
    data.value.remove(pathComp[0]);
  } else {
    data.value[pathComp[0]] = updateData;
  }
}
