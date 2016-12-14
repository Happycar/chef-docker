
How?
====

Add `ec2::assign-tags` recipe to your layers runlist

Add a section to your `Custom JSON` and set your own list of tags, eg:

```json
{
    "ec2_tags": {
        "tag_1": "foo",
        "tag_2": "bar"
    }
}
```

Ensure that the EC2 instance profile used has the ability to `CreateTags`, `DescribeTags` and `DeleteTags`.