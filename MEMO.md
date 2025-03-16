export PACKAGE_ID=0xb84460fd33aaf7f7b7f80856f27c51db6334922f79e326641fb90d40cc698175

export BLOCKBLOCK_YONSEI=0x99fd4d0ac79bb0caa94a7bcc5ed597ad9ec73dfdc0ed19079f3ea2502777d83a

export MEMBER=0x23c11df86fad8d628fe9b7fb6bf0b27be231f995b476ae1cff2a227575e96fad

# 1기

export CLUB_COHORT=0xe41bef0ada71cd87d2a5ed4c30e5106ffa23cedad1f6cbb12101dedeef99dc74
export PRESIDENT_CAP=0x73b4e1fffc47e4abecf3bf4eaf3ca807213315d80aec0816b0843c3cb39f5718
export VICE_PRESIDENT_CAP=0x55069d02c48c6b106f400e0f97ee0a63c0064db37e47e851be682020d3200cb7
export TREASURER_CAP=0xb51c72e7eb624dd3d1826f8fc954fc0f8e7495e7b63cb58d5d9902699cd168d7

# 2기

export CLUB_COHORT=0xa76152bbb1b7def284dc4f91586bfae60f62eedd9256a5b83092a62cc4f606f7
export PRESIDENT_CAP=0x6c11073500f863c62c9f82f1da8a0d87a7a8c315a1f9b6eb7151eaef8e129563
export VICE_PRESIDENT_CAP=0xab8e012823f0c0e9a684406f530879e4d7e0379996f3d45346319d3cd448725e
export TREASURER_CAP=0x670fc646ad112b21ba06afc6a2a3582bfabbbcc14f940d8ef46f6220853bf642

# functions

sui client call --package $PACKAGE_ID --module blockblock --function add_club_member --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $PRESIDENT_CAP $MEMBER

sui client call --package $PACKAGE_ID --module blockblock --function create_current_vice_president_cap --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $PRESIDENT_CAP $MEMBER

sui client call --package $PACKAGE_ID --module blockblock --function create_current_treasurer_cap --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $PRESIDENT_CAP $MEMBER

sui client call --package $PACKAGE_ID --module blockblock --function close_recruiting --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $PRESIDENT_CAP

sui client call --package $PACKAGE_ID --module blockblock --function close_cohort_by_current_president --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $PRESIDENT_CAP

sui client call --package $PACKAGE_ID --module blockblock --function close_cohort_by_current_vice_president --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $VICE_PRESIDENT_CAP

sui client call --package $PACKAGE_ID --module blockblock --function close_cohort_by_current_treasurer --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $TREASURER_CAP

sui client call --package $PACKAGE_ID --module blockblock --function create_next_cohort --args $BLOCKBLOCK_YONSEI $CLUB_COHORT $PRESIDENT_CAP $MEMBER
