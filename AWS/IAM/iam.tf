resource "aws_iam_policy" "traefik" {
  name = "route53-allow-observability.example.com"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "route53:GetChange",
          "Resource" : "arn:aws:route53:::change/*"
        },
        {
          "Effect" : "Allow",
          "Action" : "route53:ListHostedZonesByName",
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListResourceRecordSets"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/${data.aws_route53_zone.observability.zone_id}"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/${data.aws_route53_zone.observability.zone_id}"
          ],
          "Condition" : {
            "ForAllValues:StringLike" : {
              "route53:ChangeResourceRecordSetsNormalizedRecordNames" : [
                "*.${var.domain}"
              ],
              "route53:ChangeResourceRecordSetsRecordTypes" : [
                "TXT"
              ]
            }
          }
        }
      ]
    }
  )
}