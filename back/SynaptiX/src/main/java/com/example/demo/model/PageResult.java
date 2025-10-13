package com.example.demo.model;
import java.util.List;

public class PageResult<T> {
    private List<T> content;
    private int totalCount;
    private int page;
    private int size;

    public PageResult(List<T> content, int totalCount, int page, int size) {
        this.content = content;
        this.totalCount = totalCount;
        this.page = page;
        this.size = size;
    }
    public List<T> getContent() { return content; }
    public int getTotalCount() { return totalCount; }
    public int getPage() { return page; }
    public int getSize() { return size; }
}
