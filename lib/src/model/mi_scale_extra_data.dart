import 'package:xiaomi_scale/src/model/gender.dart';

class MiScaleBodyData {
  final MiScaleGender gender;
  final int age;
  final double height;
  final double weight;
  final int impedance;

  const MiScaleBodyData({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
    required this.impedance,
  });

  double get lbmCoefficient {
    var lbm = (height * 9.058 / 100.0) * (height / 100.0);
    lbm += weight * 0.32 + 12.226;
    lbm -= impedance * 0.0068;
    lbm -= age * 0.0542;

    return lbm;
  }

  double get bmi {
    return weight / (((height * height) / 100.0) / 100.0);
  }

  double get muscleMass {
    var muscleMass = weight - ((bodyFat * 0.01) * weight) - boneMass;

    if (gender == MiScaleGender.FEMALE && muscleMass >= 84.0) {
      muscleMass = 120.0;
    } else if (gender == MiScaleGender.MALE && muscleMass >= 93.5) {
      muscleMass = 120.0;
    }

    return muscleMass;
  }

  double get water {
    double coeff;
    final water = (100.0 - bodyFat) * 0.7;

    if (water < 50) {
      coeff = 1.02;
    } else {
      coeff = 0.98;
    }

    return coeff * water;
  }

  double get boneMass {
    double boneMass;
    double base;

    if (gender == MiScaleGender.FEMALE) {
      base = 0.245691014;
    } else {
      base = 0.18016894;
    }

    boneMass = (base - (lbmCoefficient * 0.05158)) * -1.0;

    if (boneMass > 2.2) {
      boneMass += 0.1;
    } else {
      boneMass -= 0.1;
    }

    if (gender == MiScaleGender.FEMALE && boneMass > 5.1) {
      boneMass = 8.0;
    } else if (gender == MiScaleGender.MALE && boneMass > 5.2) {
      boneMass = 8.0;
    }

    return boneMass;
  }

  double get visceralFat {
    var visceralFat = 0.0;
    if (gender == MiScaleGender.FEMALE) {
      if (weight > (13.0 - (height * 0.5)) * -1.0) {
        final subsubcalc =
            ((height * 1.45) + (height * 0.1158) * height) - 120.0;
        final subcalc = weight * 500.0 / subsubcalc;
        visceralFat = (subcalc - 6.0) + (age * 0.07);
      } else {
        final subcalc = 0.691 + (height * -0.0024) + (height * -0.0024);
        visceralFat = (((height * 0.027) - (subcalc * weight)) * -1.0) +
            (age * 0.07) -
            age;
      }
    } else if (gender == MiScaleGender.MALE) {
      if (height < weight * 1.6) {
        final subcalc = ((height * 0.4) - (height * (height * 0.0826))) * -1.0;
        visceralFat =
            ((weight * 305.0) / (subcalc + 48.0)) - 2.9 + (age * 0.15);
      } else {
        final subcalc = 0.765 + height * -0.0015;
        visceralFat = (((height * 0.143) - (weight * subcalc)) * -1.0) +
            (age * 0.15) -
            5.0;
      }
    }

    return visceralFat;
  }

  double get bodyFat {
    var bodyFat = 0.0;
    var lbmSub = 0.8;

    if (gender == MiScaleGender.FEMALE && age <= 49) {
      lbmSub = 9.25;
    } else if (gender == MiScaleGender.MALE && age > 49) {
      lbmSub = 7.25;
    }

    final lbmCoeff = lbmCoefficient;
    var coeff = 1.0;

    if (gender == MiScaleGender.MALE && weight < 61.0) {
      coeff = 0.98;
    } else if (gender == MiScaleGender.FEMALE && weight > 60.0) {
      coeff = 0.96;

      if (height > 160.0) {
        coeff *= 1.03;
      }
    } else if (gender == MiScaleGender.FEMALE && weight < 50.0) {
      coeff = 1.02;

      if (height > 160.0) {
        coeff *= 1.03;
      }
    }

    bodyFat = (1.0 - (((lbmCoeff - lbmSub) * coeff) / weight)) * 100.0;

    if (bodyFat > 63.0) {
      bodyFat = 75.0;
    }

    return bodyFat;
  }

  double get bmr {
    var bmr = 0.0;

    if (gender == MiScaleGender.FEMALE) {
      bmr = 864.6 + (weight * 10.2036);
      bmr -= height * 0.39336;
      bmr -= age * 6.204;
      if (bmr > 2996) {
        bmr = 5000;
      }
    } else {
      bmr = 877.8 + (weight * 14.916);
      bmr -= height * 0.726;
      bmr -= age * 8.976;
      if (bmr > 2322) {
        bmr = 5000;
      }
    }
    if (bmr < 500) {
      bmr = 500;
    }
    return bmr;
  }

  double get metabolicAge {
    var metabolicAge = 0.0;

    if (gender == MiScaleGender.FEMALE) {
      metabolicAge = (height * -1.1165) +
          (weight * 1.5784) +
          (age * 0.4615) +
          (impedance * 0.0415) +
          83.2548;
    } else {
      metabolicAge = (height * -0.7471) +
          (weight * 0.9161) +
          (age * 0.4184) +
          (impedance * 0.0517) +
          54.2267;
    }
    if (metabolicAge < 15) {
      metabolicAge = 15;
    }
    if (metabolicAge > 80) {
      metabolicAge = 80;
    }

    return metabolicAge;
  }

  int get bodyType {
    var factor = 0;

    if (bodyFat > fatPercentageScale()[2]) {
      factor = 0;
    } else {
      if (bodyFat < fatPercentageScale()[1]) {
        factor = 2;
      } else {
        factor = 1;
      }
    }

    if (muscleMass > muscleMassScale()[1]) {
      factor = 2 + (factor * 3);
    } else {
      if (muscleMass < muscleMassScale()[0]) {
        factor = (factor * 3);
      } else {
        factor = 1 + (factor * 3);
      }
    }
    return factor;
  }

  List<dynamic> fatPercentageScale() {
    List skala = [];
    List scales = [
      {
        'min': 0,
        'max': 11,
        'female': [12, 21, 30, 34],
        'male': [7, 16, 25, 30]
      },
      {
        'min': 12,
        'max': 13,
        'female': [15, 24, 33, 37],
        'male': [7, 16, 25, 30]
      },
      {
        'min': 14,
        'max': 15,
        'female': [18, 27, 36, 40],
        'male': [7, 16, 25, 30]
      },
      {
        'min': 16,
        'max': 17,
        'female': [20, 28, 37, 41],
        'male': [7, 16, 25, 30]
      },
      {
        'min': 18,
        'max': 39,
        'female': [21, 28, 35, 40],
        'male': [11, 17, 22, 27]
      },
      {
        'min': 40,
        'max': 59,
        'female': [22, 29, 36, 41],
        'male': [12, 18, 23, 28]
      },
      {
        'min': 60,
        'max': 100,
        'female': [23, 30, 37, 42],
        'male': [14, 20, 25, 30]
      },
    ];

    for (var i = 0; i < scales.length; i++) {
      if (age >= scales[i]['min'] && age <= scales[i]['max']) {
        if (gender == MiScaleGender.FEMALE) {
          skala = scales[i]['female'];
        } else {
          skala = scales[i]['male'];
        }
      }
    }

    return skala;
  }

  List<dynamic> muscleMassScale() {
    List skala = [];
    List scales = [
      {
        'min_male': 170,
        'min_female': 160,
        'female': [36.5, 42.6],
        'male': [49.4, 59.5]
      },
      {
        'min_male': 160,
        'min_female': 150,
        'female': [32.9, 37.6],
        'male': [44.0, 52.5]
      },
      {
        'min_male': 0,
        'min_female': 0,
        'female': [29.1, 34.8],
        'male': [38.5, 46.6]
      },
    ];
    for (var i = 0; i < scales.length; i++) {
      if (gender == MiScaleGender.FEMALE) {
        if (height >= scales[i]['min_female']) {
          skala = scales[i]['female'];
        }
      } else {
        if (height >= scales[i]['min_male']) {
          skala = scales[i]['male'];
        }
      }
    }
    return skala;
  }

  String get bodyTypeScale {
    List skala = [
      'obese',
      'overweight',
      'thick-set',
      'lack-exerscise',
      'balanced',
      'balanced-muscular',
      'skinny',
      'balanced-skinny',
      'skinny-muscular'
    ];
    return skala[bodyType + 1];
  }
}
